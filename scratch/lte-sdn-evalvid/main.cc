/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */
/*
 * Simulação LTE + SDN + EvalVid
 * 
 * Cenário:
 * - 2 eNodeBs (multi-cell com handover X2)
 * - 4 UEs móveis (transitando entre as torres)
 * - 1 Switch SDN (ofswitch13) entre PGW e servidor de vídeo
 * - 1 Servidor de vídeo remoto (remoteHost)
 * - EvalVid configurado para 2 vídeos diferentes
 * 
 * Modos:
 * - enableSdn=false: Switch atua como comutador normal (learning switch)
 * - enableSdn=true: Switch aplica regras OpenFlow para priorizar vídeo
 * 
 * Arquitetura de Rede:
 * 
 *   [UE1]---+                                    +---[VideoServer]
 *   [UE2]---+--[eNB1]--+             +--[SDN Switch]--+
 *   [UE3]---+          |             |                |
 *   [UE4]---+--[eNB2]--+--[PGW/SGW]--+                +---[Controller]
 *                      |
 *                    (X2)
 */

#include <fstream>
#include <iomanip>
#include <sstream>

#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/internet-module.h"
#include "ns3/point-to-point-module.h"
#include "ns3/csma-module.h"
#include "ns3/lte-module.h"
#include "ns3/epc-helper.h"
#include "ns3/point-to-point-epc-helper.h"
#include "ns3/mobility-module.h"
#include "ns3/applications-module.h"
#include "ns3/evalvid-client-server-helper.h"
#include "ns3/flow-monitor-module.h"
#include "ns3/ipv4-global-routing-helper.h"
#include "ns3/ofswitch13-module.h"
#include "ns3/bridge-module.h"

// Incluir o controlador customizado
#include "video-qos-controller.h"

// Use namespace somente após os includes do ofswitch13
using namespace ns3;

NS_LOG_COMPONENT_DEFINE ("LteSdnEvalvid");

int main (int argc, char *argv[])
{
  // ======= Parâmetros de Simulação =======
  uint16_t numEnbs = 2;        // 2 eNodeBs (requisito mínimo)
  uint16_t numUes = 4;         // 4 UEs (entre 3 e 6)
  double simTime = 60.0;       // Tempo de simulação em segundos
  double areaX = 400.0;        // Área X em metros
  double areaY = 400.0;        // Área Y em metros
  double ueSpeedKmph = 30.0;   // Velocidade dos UEs em km/h
  uint16_t basePort = 8000;    // Porta base para EvalVid
  bool enableSdn = true;       // Ativa/desativa priorização SDN
  bool verbose = false;        // Logs detalhados
  bool trace = false;          // Habilita traces pcap
  std::string video1 = "st_highway_cif.st";   // Primeiro vídeo
  std::string video2 = "football.st";         // Segundo vídeo
  std::string outputPrefix = "sdn";           // Prefixo para arquivos de saída

  CommandLine cmd;
  cmd.AddValue ("numEnbs", "Número de eNodeBs", numEnbs);
  cmd.AddValue ("numUes", "Número de UEs (3-6)", numUes);
  cmd.AddValue ("simTime", "Tempo de simulação (s)", simTime);
  cmd.AddValue ("enableSdn", "Ativa priorização SDN (true/false)", enableSdn);
  cmd.AddValue ("verbose", "Ativa logs detalhados", verbose);
  cmd.AddValue ("trace", "Ativa traces pcap", trace);
  cmd.AddValue ("video1", "Arquivo de trace do vídeo 1", video1);
  cmd.AddValue ("video2", "Arquivo de trace do vídeo 2", video2);
  cmd.AddValue ("outputPrefix", "Prefixo para arquivos de saída", outputPrefix);
  cmd.Parse (argc, argv);

  // Validações
  if (numUes < 3 || numUes > 6)
    {
      NS_LOG_WARN ("Número de UEs ajustado para o intervalo 3-6");
      numUes = std::max ((uint16_t)3, std::min ((uint16_t)6, numUes));
    }
  if (numEnbs < 2)
    {
      NS_LOG_WARN ("Número mínimo de eNodeBs é 2");
      numEnbs = 2;
    }

  double ueSpeedMs = ueSpeedKmph * 1000.0 / 3600.0;

  // ======= Configuração de Logs =======
  if (verbose)
    {
      LogComponentEnable ("LteSdnEvalvid", LOG_LEVEL_INFO);
      LogComponentEnable ("EvalvidClient", LOG_LEVEL_INFO);
      LogComponentEnable ("EvalvidServer", LOG_LEVEL_INFO);
      LogComponentEnable ("VideoQosController", LOG_LEVEL_INFO);
      OFSwitch13Helper::EnableDatapathLogs ();
    }
  else
    {
      LogComponentEnable ("EvalvidClient", LOG_LEVEL_INFO);
      LogComponentEnable ("EvalvidServer", LOG_LEVEL_INFO);
    }

  // ======= Habilitar checksums (necessário para OFSwitch13) =======
  GlobalValue::Bind ("ChecksumEnabled", BooleanValue (true));

  NS_LOG_INFO ("=== Iniciando Simulação LTE + SDN + EvalVid ===");
  NS_LOG_INFO ("Modo SDN: " << (enableSdn ? "ATIVADO (com priorização)" : "DESATIVADO (switch normal)"));
  NS_LOG_INFO ("eNodeBs: " << numEnbs << ", UEs: " << numUes);
  NS_LOG_INFO ("Vídeos: " << video1 << " e " << video2);

  // ======= LTE + EPC =======
  Ptr<LteHelper> lteHelper = CreateObject<LteHelper> ();
  Ptr<PointToPointEpcHelper> epcHelper = CreateObject<PointToPointEpcHelper> ();
  lteHelper->SetEpcHelper (epcHelper);
  lteHelper->SetSchedulerType ("ns3::PfFfMacScheduler");
  
  // Configurações para melhorar handover
  lteHelper->SetHandoverAlgorithmType ("ns3::A3RsrpHandoverAlgorithm");
  lteHelper->SetHandoverAlgorithmAttribute ("Hysteresis", DoubleValue (3.0));
  lteHelper->SetHandoverAlgorithmAttribute ("TimeToTrigger", TimeValue (MilliSeconds (256)));

  Ptr<Node> pgw = epcHelper->GetPgwNode ();

  // ======= Criação dos Nós =======
  NodeContainer remoteHostContainer;
  remoteHostContainer.Create (1);
  Ptr<Node> remoteHost = remoteHostContainer.Get (0);

  // Nó do switch SDN
  Ptr<Node> switchNode = CreateObject<Node> ();
  
  // Nó do controlador SDN
  Ptr<Node> controllerNode = CreateObject<Node> ();

  // ======= Conexões de Rede com Switch SDN =======
  // 
  // [PGW] ---- [SDN Switch] ---- [RemoteHost]
  //                |
  //          [Controller]

  CsmaHelper csmaHelper;
  csmaHelper.SetChannelAttribute ("DataRate", DataRateValue (DataRate ("100Mbps")));
  csmaHelper.SetChannelAttribute ("Delay", TimeValue (MicroSeconds (100)));

  // Conexão PGW <-> Switch
  NetDeviceContainer linkPgwSwitch;
  NodeContainer pairPgwSwitch (pgw, switchNode);
  linkPgwSwitch = csmaHelper.Install (pairPgwSwitch);

  // Conexão Switch <-> RemoteHost
  NetDeviceContainer linkSwitchHost;
  NodeContainer pairSwitchHost (switchNode, remoteHost);
  linkSwitchHost = csmaHelper.Install (pairSwitchHost);

  // Portas do switch (conectando PGW e RemoteHost)
  NetDeviceContainer switchPorts;
  switchPorts.Add (linkPgwSwitch.Get (1));   // Porta 1: para PGW
  switchPorts.Add (linkSwitchHost.Get (0));  // Porta 2: para RemoteHost

  // Dispositivos dos hosts
  NetDeviceContainer pgwDevice;
  pgwDevice.Add (linkPgwSwitch.Get (0));
  
  NetDeviceContainer remoteHostDevice;
  remoteHostDevice.Add (linkSwitchHost.Get (1));

  // ======= Configuração do Switch SDN =======
  Ptr<OFSwitch13InternalHelper> ofHelper = CreateObject<OFSwitch13InternalHelper> ();
  
  // Criar e configurar o controlador
  Ptr<VideoQosController> controller = CreateObject<VideoQosController> ();
  controller->SetAttribute ("EnableQos", BooleanValue (enableSdn));
  controller->SetAttribute ("VideoPortStart", UintegerValue (basePort));
  controller->SetAttribute ("VideoPortEnd", UintegerValue (basePort + numUes + 10));
  
  ofHelper->InstallController (controllerNode, controller);
  ofHelper->InstallSwitch (switchNode, switchPorts);
  ofHelper->CreateOpenFlowChannels ();

  // ======= Configuração IP para Internet =======
  InternetStackHelper internet;
  internet.Install (remoteHost);

  // Endereços IP
  Ipv4AddressHelper ipv4h;
  ipv4h.SetBase ("1.0.0.0", "255.255.255.0");
  
  Ipv4InterfaceContainer pgwIpIface = ipv4h.Assign (pgwDevice);
  Ipv4InterfaceContainer remoteHostIpIface = ipv4h.Assign (remoteHostDevice);
  
  Ipv4Address remoteHostAddr = remoteHostIpIface.GetAddress (0);
  
  NS_LOG_INFO ("Remote Host IP: " << remoteHostAddr);

  // Rota no RemoteHost para a rede dos UEs
  Ipv4StaticRoutingHelper ipv4RoutingHelper;
  Ptr<Ipv4StaticRouting> remoteHostStaticRouting =
      ipv4RoutingHelper.GetStaticRouting (remoteHost->GetObject<Ipv4> ());
  remoteHostStaticRouting->AddNetworkRouteTo (Ipv4Address ("7.0.0.0"),
                                              Ipv4Mask ("255.0.0.0"), 1);

  // ======= Criação de eNBs e UEs =======
  NodeContainer enbNodes, ueNodes;
  enbNodes.Create (numEnbs);
  ueNodes.Create (numUes);

  // ======= Posição dos eNBs =======
  MobilityHelper enbMobility;
  Ptr<ListPositionAllocator> enbPosAlloc = CreateObject<ListPositionAllocator> ();
  
  // Posiciona eNBs em linha horizontal no centro da área
  double enbSpacing = areaX / (numEnbs + 1);
  for (uint32_t i = 0; i < numEnbs; ++i)
    {
      double x = enbSpacing * (i + 1);
      double y = areaY / 2.0;
      enbPosAlloc->Add (Vector (x, y, 30.0)); // Altura de 30m
      NS_LOG_INFO ("eNB " << i << " posição: (" << x << ", " << y << ", 30)");
    }
  
  enbMobility.SetPositionAllocator (enbPosAlloc);
  enbMobility.SetMobilityModel ("ns3::ConstantPositionMobilityModel");
  enbMobility.Install (enbNodes);

  // ======= Mobilidade dos UEs =======
  MobilityHelper ueMobility;
  ObjectFactory pos;
  pos.SetTypeId ("ns3::RandomRectanglePositionAllocator");
  std::ostringstream xRange, yRange;
  xRange << "ns3::UniformRandomVariable[Min=0.0|Max=" << areaX << "]";
  yRange << "ns3::UniformRandomVariable[Min=0.0|Max=" << areaY << "]";
  pos.Set ("X", StringValue (xRange.str ()));
  pos.Set ("Y", StringValue (yRange.str ()));
  Ptr<PositionAllocator> uePosAlloc = pos.Create ()->GetObject<PositionAllocator> ();

  std::ostringstream speedStr;
  speedStr << "ns3::ConstantRandomVariable[Constant=" << ueSpeedMs << "]";
  ueMobility.SetPositionAllocator (uePosAlloc);
  ueMobility.SetMobilityModel ("ns3::RandomWaypointMobilityModel",
                               "Speed", StringValue (speedStr.str ()),
                               "Pause", StringValue ("ns3::ConstantRandomVariable[Constant=1.0]"),
                               "PositionAllocator", PointerValue (uePosAlloc));
  ueMobility.Install (ueNodes);

  // ======= Instala dispositivos LTE =======
  NetDeviceContainer enbLteDevs = lteHelper->InstallEnbDevice (enbNodes);
  NetDeviceContainer ueLteDevs = lteHelper->InstallUeDevice (ueNodes);

  // ======= Ativa handover X2 =======
  lteHelper->AddX2Interface (enbNodes);
  NS_LOG_INFO ("Interface X2 configurada para handover entre eNBs");

  // ======= IP nos UEs =======
  internet.Install (ueNodes);
  Ipv4InterfaceContainer ueIpIface =
      epcHelper->AssignUeIpv4Address (NetDeviceContainer (ueLteDevs));

  // Rota padrão nos UEs
  for (uint32_t u = 0; u < ueNodes.GetN (); ++u)
    {
      Ptr<Node> node = ueNodes.Get (u);
      Ptr<Ipv4StaticRouting> ueStaticRouting =
          ipv4RoutingHelper.GetStaticRouting (node->GetObject<Ipv4> ());
      ueStaticRouting->SetDefaultRoute (epcHelper->GetUeDefaultGatewayAddress (), 1);
    }

  // Attach inicial dos UEs aos eNBs (balanceado)
  for (uint32_t u = 0; u < ueLteDevs.GetN (); ++u)
    {
      uint32_t enbIndex = u % enbLteDevs.GetN ();
      lteHelper->Attach (ueLteDevs.Get (u), enbLteDevs.Get (enbIndex));
      NS_LOG_INFO ("UE " << u << " (IP: " << ueIpIface.GetAddress (u) 
                   << ") attached ao eNB " << enbIndex);
    }

  // ======= Aplicações EvalVid - Dois Vídeos Diferentes =======
  ApplicationContainer serverApps, clientApps;
  
  // Divide os UEs entre os dois vídeos
  uint32_t halfUes = numUes / 2;
  
  for (uint32_t u = 0; u < ueNodes.GetN (); ++u)
    {
      uint16_t port = basePort + u;
      std::string videoFile = (u < halfUes) ? video1 : video2;
      std::string videoName = (u < halfUes) ? "video1" : "video2";
      
      // Servidor EvalVid no RemoteHost
      EvalvidServerHelper server (port);
      server.SetAttribute ("SenderTraceFilename", StringValue (videoFile));
      
      std::ostringstream sdname;
      sdname << outputPrefix << "_sd_" << videoName << "_ue" << (u + 1);
      server.SetAttribute ("SenderDumpFilename", StringValue (sdname.str ()));
      
      ApplicationContainer sa = server.Install (remoteHost);
      sa.Start (Seconds (1.0 + u * 0.1));
      sa.Stop (Seconds (simTime - 1.0));
      serverApps.Add (sa);

      // Cliente EvalVid no UE
      EvalvidClientHelper client (remoteHostAddr, port);
      
      std::ostringstream rdname;
      rdname << outputPrefix << "_rd_" << videoName << "_ue" << (u + 1);
      client.SetAttribute ("ReceiverDumpFilename", StringValue (rdname.str ()));
      
      ApplicationContainer ca = client.Install (ueNodes.Get (u));
      ca.Start (Seconds (2.0 + u * 0.1));
      ca.Stop (Seconds (simTime - 5.0));
      clientApps.Add (ca);
      
      NS_LOG_INFO ("UE " << u << " configurado com " << videoFile 
                   << " na porta " << port);
    }

  // ======= FlowMonitor =======
  FlowMonitorHelper flowmon;
  Ptr<FlowMonitor> monitor = flowmon.InstallAll ();

  // ======= Traces PCAP (opcional) =======
  if (trace)
    {
      ofHelper->EnableOpenFlowPcap (outputPrefix + "_openflow");
      ofHelper->EnableDatapathStats (outputPrefix + "_switch-stats");
      csmaHelper.EnablePcap (outputPrefix + "_switch", switchPorts, true);
    }

  // ======= Execução =======
  NS_LOG_INFO ("Iniciando simulação por " << simTime << " segundos...");
  Simulator::Stop (Seconds (simTime));
  Simulator::Run ();

  // ======= Processamento de Métricas =======
  NS_LOG_INFO ("Processando métricas...");
  
  Ptr<Ipv4FlowClassifier> classifier = 
      DynamicCast<Ipv4FlowClassifier> (flowmon.GetClassifier ());
  std::map<FlowId, FlowMonitor::FlowStats> stats = monitor->GetFlowStats ();

  std::ostringstream fVazaoName, fPerdaName, fJitterName, fDelayName;
  fVazaoName << outputPrefix << "_QoS_vazao.txt";
  fPerdaName << outputPrefix << "_QoS_perda.txt";
  fJitterName << outputPrefix << "_QoS_jitter.txt";
  fDelayName << outputPrefix << "_QoS_delay.txt";

  std::ofstream fVazao (fVazaoName.str ().c_str ());
  std::ofstream fPerda (fPerdaName.str ().c_str ());
  std::ofstream fJitter (fJitterName.str ().c_str ());
  std::ofstream fDelay (fDelayName.str ().c_str ());

  fVazao << "# Flow ID, Source IP, Dest IP, Throughput (Mbps)" << std::endl;
  fPerda << "# Flow ID, Lost Packets, Total Packets, Loss Ratio (%)" << std::endl;
  fJitter << "# Flow ID, Mean Jitter (ms)" << std::endl;
  fDelay << "# Flow ID, Mean Delay (ms)" << std::endl;

  double totalThroughput = 0.0;
  double totalLossRatio = 0.0;
  double totalJitter = 0.0;
  double totalDelay = 0.0;
  uint32_t flowCount = 0;

  std::vector<double> ueThroughput (ueNodes.GetN (), 0.0);

  for (auto &it : stats)
    {
      Ipv4FlowClassifier::FiveTuple t = classifier->FindFlow (it.first);
      
      double timeFirst = it.second.timeFirstTxPacket.GetSeconds ();
      double timeLast = it.second.timeLastRxPacket.GetSeconds ();
      double duration = (timeLast - timeFirst > 0.0) ? (timeLast - timeFirst) : 1e-9;
      
      double rxBytes = (double) it.second.rxBytes;
      double throughput = (rxBytes * 8.0) / (duration * 1e6); // Mbps
      
      double lossRatio = (it.second.txPackets > 0) 
          ? ((double) it.second.lostPackets / it.second.txPackets * 100.0) 
          : 0.0;
      
      double jitterMean = (it.second.rxPackets > 1)
          ? (it.second.jitterSum.GetMilliSeconds () / (it.second.rxPackets - 1))
          : 0.0;
      
      double delayMean = (it.second.rxPackets > 0)
          ? (it.second.delaySum.GetMilliSeconds () / it.second.rxPackets)
          : 0.0;

      // Identificar UE destino
      int ueIndex = -1;
      for (uint32_t u = 0; u < ueIpIface.GetN (); ++u)
        {
          if (ueIpIface.GetAddress (u) == t.destinationAddress)
            {
              ueIndex = u;
              break;
            }
        }

      if (ueIndex >= 0)
        {
          ueThroughput[ueIndex] += throughput;
        }

      // Salvar nos arquivos
      fVazao << it.first << ", " << t.sourceAddress << ", " 
             << t.destinationAddress << ", " << throughput << std::endl;
      
      fPerda << it.first << ", " << it.second.lostPackets << ", " 
             << it.second.txPackets << ", " << lossRatio << std::endl;
      
      fJitter << it.first << ", " << jitterMean << std::endl;
      fDelay << it.first << ", " << delayMean << std::endl;

      totalThroughput += throughput;
      totalLossRatio += lossRatio;
      totalJitter += jitterMean;
      totalDelay += delayMean;
      flowCount++;
    }

  fVazao.close ();
  fPerda.close ();
  fJitter.close ();
  fDelay.close ();

  // ======= Métricas por UE =======
  for (uint32_t u = 0; u < ueNodes.GetN (); ++u)
    {
      std::ostringstream fname;
      fname << outputPrefix << "_QoS_ue" << (u + 1) << ".txt";
      std::ofstream fUe (fname.str ().c_str ());
      
      std::string videoUsed = (u < halfUes) ? video1 : video2;
      fUe << "UE " << (u + 1) << std::endl;
      fUe << "Video: " << videoUsed << std::endl;
      fUe << "IP: " << ueIpIface.GetAddress (u) << std::endl;
      fUe << "Throughput total: " << ueThroughput[u] << " Mbps" << std::endl;
      
      Ptr<MobilityModel> mob = ueNodes.Get (u)->GetObject<MobilityModel> ();
      Vector pos = mob->GetPosition ();
      fUe << "Posição final: x=" << pos.x << " y=" << pos.y << std::endl;
      fUe.close ();
    }

  // ======= Resumo =======
  std::ostringstream summaryName;
  summaryName << outputPrefix << "_resumo.txt";
  std::ofstream fSummary (summaryName.str ().c_str ());
  
  fSummary << "=== RESUMO DA SIMULAÇÃO ===" << std::endl;
  fSummary << "Modo SDN: " << (enableSdn ? "ATIVADO" : "DESATIVADO") << std::endl;
  fSummary << "eNodeBs: " << numEnbs << std::endl;
  fSummary << "UEs: " << numUes << std::endl;
  fSummary << "Tempo de simulação: " << simTime << " s" << std::endl;
  fSummary << "Vídeo 1: " << video1 << " (UEs 1-" << halfUes << ")" << std::endl;
  fSummary << "Vídeo 2: " << video2 << " (UEs " << (halfUes+1) << "-" << numUes << ")" << std::endl;
  fSummary << std::endl;
  fSummary << "=== MÉTRICAS MÉDIAS ===" << std::endl;
  if (flowCount > 0)
    {
      fSummary << "Throughput médio: " << (totalThroughput / flowCount) << " Mbps" << std::endl;
      fSummary << "Taxa de perda média: " << (totalLossRatio / flowCount) << " %" << std::endl;
      fSummary << "Jitter médio: " << (totalJitter / flowCount) << " ms" << std::endl;
      fSummary << "Delay médio: " << (totalDelay / flowCount) << " ms" << std::endl;
    }
  fSummary << "Total de fluxos: " << flowCount << std::endl;
  fSummary.close ();

  monitor->SerializeToXmlFile (outputPrefix + "_flowmonitor.xml", true, true);

  // ======= Limpeza =======
  Simulator::Destroy ();
  
  NS_LOG_INFO ("=== Simulação concluída ===");
  NS_LOG_INFO ("Arquivos gerados com prefixo: " << outputPrefix);

  return 0;
}
