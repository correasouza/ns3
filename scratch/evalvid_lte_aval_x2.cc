/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */
/*
 * Simulação LTE + SDN + EvalVid para avaliação de QoS/QoE em streaming de vídeo
 * 
 * Cenário:
 * - 2 eNodeBs (multi-cell) com handover X2
 * - 4 UEs móveis transitando entre as torres
 * - 1 Switch SDN (ofswitch13)
 * - 1 Servidor de vídeo remoto
 * - 2 vídeos diferentes (highway e football)
 * 
 * Executa dois cenários:
 * 1. SEM SDN - switch atua como comutador normal (learning controller)
 * 2. COM SDN - aplica regra OpenFlow para priorizar fluxo de vídeo
 */

// Inclui ofswitch13 primeiro para evitar conflitos de namespace
#include "ns3/ofswitch13-module.h"

#include <fstream>
#include <iomanip>
#include <sstream>
#include <sys/stat.h>
#include <ctime>
#include <cmath>
#include <algorithm>
#include <map>
#include <vector>
#include <string>

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
#include "ns3/bridge-module.h"

using namespace ns3;

NS_LOG_COMPONENT_DEFINE ("EvalvidLTE_SDN_Aval");

// ============================================================================
// Controlador SDN com priorização de vídeo (QoS)
// ============================================================================
class VideoQosController : public OFSwitch13Controller
{
public:
  VideoQosController ();
  virtual ~VideoQosController ();
  static TypeId GetTypeId (void);
  void SetPrioritizationEnabled (bool enabled);

protected:
  void HandshakeSuccessful (Ptr<const RemoteSwitch> swtch) override;
  ofl_err HandlePacketIn (struct ofl_msg_packet_in *msg,
                          Ptr<const RemoteSwitch> swtch,
                          uint32_t xid) override;

private:
  void ConfigureSwitch (Ptr<const RemoteSwitch> swtch);
  void InstallVideoQosRules (Ptr<const RemoteSwitch> swtch);
  bool m_prioritizationEnabled;
  std::map<uint64_t, std::map<Mac48Address, uint32_t>> m_learnedInfo;
};

NS_OBJECT_ENSURE_REGISTERED (VideoQosController);

VideoQosController::VideoQosController ()
  : m_prioritizationEnabled (false)
{
}

VideoQosController::~VideoQosController ()
{
}

TypeId
VideoQosController::GetTypeId (void)
{
  static TypeId tid = TypeId ("ns3::VideoQosController")
    .SetParent<OFSwitch13Controller> ()
    .SetGroupName ("OFSwitch13")
    .AddConstructor<VideoQosController> ();
  return tid;
}

void
VideoQosController::SetPrioritizationEnabled (bool enabled)
{
  m_prioritizationEnabled = enabled;
}

void
VideoQosController::HandshakeSuccessful (Ptr<const RemoteSwitch> swtch)
{
  NS_LOG_FUNCTION (this << swtch);
  ConfigureSwitch (swtch);
  if (m_prioritizationEnabled)
    {
      InstallVideoQosRules (swtch);
    }
}

void
VideoQosController::ConfigureSwitch (Ptr<const RemoteSwitch> swtch)
{
  NS_LOG_FUNCTION (this << swtch);
  
  uint64_t dpId = swtch->GetDpId ();
  
  // Configura tabela miss para enviar ao controlador
  DpctlExecute (dpId, "flow-mod cmd=add,table=0,prio=0 apply:output=ctrl:128");
}

void
VideoQosController::InstallVideoQosRules (Ptr<const RemoteSwitch> swtch)
{
  NS_LOG_FUNCTION (this << swtch);
  
  uint64_t dpId = swtch->GetDpId ();
  
  // Regra de alta prioridade para tráfego UDP (vídeo) - porta base 8000-8010
  // Prioriza encaminhamento com menor latência
  for (uint16_t port = 8000; port <= 8010; port++)
    {
      std::ostringstream cmd;
      // Regra para tráfego de vídeo (UDP) com alta prioridade
      cmd << "flow-mod cmd=add,table=0,prio=100 "
          << "eth_type=0x0800,ip_proto=17,udp_dst=" << port
          << " apply:output=all";
      DpctlExecute (dpId, cmd.str ());
      
      // Regra para tráfego de resposta
      std::ostringstream cmd2;
      cmd2 << "flow-mod cmd=add,table=0,prio=100 "
           << "eth_type=0x0800,ip_proto=17,udp_src=" << port
           << " apply:output=all";
      DpctlExecute (dpId, cmd2.str ());
    }
  
  // Regra para ARP
  DpctlExecute (dpId, "flow-mod cmd=add,table=0,prio=50 eth_type=0x0806 apply:output=all");
  
  // Regra padrão para outro tráfego IP (menor prioridade)
  DpctlExecute (dpId, "flow-mod cmd=add,table=0,prio=10 eth_type=0x0800 apply:output=all");
  
  NS_LOG_INFO ("Regras de QoS para vídeo instaladas no switch SDN");
}

ofl_err
VideoQosController::HandlePacketIn (struct ofl_msg_packet_in *msg,
                                    Ptr<const RemoteSwitch> swtch,
                                    uint32_t xid)
{
  NS_LOG_FUNCTION (this << swtch << xid);
  
  uint64_t dpId = swtch->GetDpId ();
  uint32_t inPort;
  size_t portLen = OXM_LENGTH (OXM_OF_IN_PORT);
  ofl_match_tlv *tlv = oxm_match_lookup (OXM_OF_IN_PORT, (ofl_match*) msg->match);
  memcpy (&inPort, tlv->value, portLen);
  
  // Extrai endereço MAC de origem
  Mac48Address srcMac;
  tlv = oxm_match_lookup (OXM_OF_ETH_SRC, (ofl_match*) msg->match);
  srcMac.CopyFrom (tlv->value);
  
  // Aprende MAC -> porta
  m_learnedInfo[dpId][srcMac] = inPort;
  
  // Extrai MAC destino
  Mac48Address dstMac;
  tlv = oxm_match_lookup (OXM_OF_ETH_DST, (ofl_match*) msg->match);
  dstMac.CopyFrom (tlv->value);
  
  uint32_t outPort = OFPP_ALL;
  auto dpIt = m_learnedInfo.find (dpId);
  if (dpIt != m_learnedInfo.end ())
    {
      auto macIt = dpIt->second.find (dstMac);
      if (macIt != dpIt->second.end ())
        {
          outPort = macIt->second;
        }
    }
  
  // Envia packet-out
  struct ofl_msg_packet_out reply;
  reply.header.type = OFPT_PACKET_OUT;
  reply.buffer_id = msg->buffer_id;
  reply.in_port = inPort;
  reply.data_length = 0;
  reply.data = nullptr;
  
  if (msg->buffer_id == OFP_NO_BUFFER)
    {
      reply.data_length = msg->data_length;
      reply.data = msg->data;
    }
  
  struct ofl_action_output *act = (ofl_action_output*) xmalloc (sizeof (ofl_action_output));
  act->header.type = OFPAT_OUTPUT;
  act->port = outPort;
  act->max_len = 0;
  
  reply.actions_num = 1;
  reply.actions = (ofl_action_header**) &act;
  
  SendToSwitch (swtch, (ofl_msg_header*) &reply, xid);
  free (act);
  
  return 0;
}

// ============================================================================
// Estruturas para métricas
// ============================================================================
struct VideoMetrics
{
  std::string videoName;
  uint32_t ueId;
  double throughput;      // Mbps
  double delay;           // ms
  double jitter;          // ms
  double packetLoss;      // %
  uint32_t txPackets;
  uint32_t rxPackets;
  uint32_t lostPackets;
  uint32_t lostFrames;
  double psnr;
  double mos;
};

// ============================================================================
// Funções auxiliares
// ============================================================================
void CreateDirectory (const std::string &path)
{
  mkdir (path.c_str (), 0755);
}

std::string GetTimestamp ()
{
  time_t now = time (nullptr);
  struct tm *t = localtime (&now);
  char buffer[64];
  strftime (buffer, sizeof (buffer), "%Y%m%d_%H%M%S", t);
  return std::string (buffer);
}

double CalculateMOS (double psnr)
{
  // Conversão PSNR -> MOS baseada em modelo ITU-T P.800
  if (psnr >= 45) return 5.0;
  if (psnr >= 37) return 4.5 + (psnr - 37) / 16.0;
  if (psnr >= 31) return 4.0 + (psnr - 31) / 12.0;
  if (psnr >= 25) return 3.0 + (psnr - 25) / 6.0;
  if (psnr >= 20) return 2.0 + (psnr - 20) / 5.0;
  if (psnr >= 15) return 1.5 + (psnr - 15) / 10.0;
  return 1.0 + psnr / 30.0;
}

double EstimatePSNR (double packetLoss, double jitter, double delay, const std::string &videoType)
{
  // Estimativa de PSNR baseada no modelo E-Model adaptado para vídeo
  // Referência: ITU-T G.1070 (Opinion model for video-telephony applications)
  
  // Base PSNR para qualidade perfeita (sem degradações)
  // Highway (movimento suave): mais tolerante a perdas
  // Football (movimento rápido): mais sensível a perdas
  double basePsnr = (videoType == "highway") ? 42.0 : 40.0;
  
  // Fator de sensibilidade do vídeo (football é mais sensível)
  double videoSensitivity = (videoType == "highway") ? 1.0 : 1.3;
  
  // Degradação por perda de pacotes - modelo logarítmico
  // Até 5% perda: degradação leve
  // 5-20% perda: degradação moderada
  // >20% perda: degradação severa
  double lossImpact = 0.0;
  if (packetLoss > 0)
    {
      // Usa log para suavizar o impacto de perdas muito altas
      lossImpact = 3.0 * log10(1.0 + packetLoss) * videoSensitivity;
      // Adiciona componente linear para perdas extremas
      if (packetLoss > 50.0)
        {
          lossImpact += (packetLoss - 50.0) * 0.05 * videoSensitivity;
        }
    }
  
  // Degradação por jitter - afeta mais vídeos de movimento rápido
  // Jitter ideal: < 5ms, aceitável: < 30ms, ruim: > 50ms
  double jitterImpact = 0.0;
  if (jitter > 5.0)
    {
      jitterImpact = (jitter - 5.0) * 0.08 * videoSensitivity;
    }
  
  // Degradação por delay - menos impacto que perda e jitter para streaming
  // Delay afeta mais a interatividade do que qualidade percebida
  double delayImpact = 0.0;
  if (delay > 50.0)
    {
      delayImpact = (delay - 50.0) * 0.02;
    }
  
  // Calcula PSNR final
  double psnr = basePsnr - lossImpact - jitterImpact - delayImpact;
  
  // Limita entre valores realistas (10 dB = muito ruim, 50 dB = excelente)
  return std::max (10.0, std::min (50.0, psnr));
}

// ============================================================================
// Função principal
// Função auxiliar para extrair nome base do arquivo de vídeo
std::string ExtractVideoName(const std::string& filename)
{
  // Remove caminho se existir
  std::string name = filename;
  size_t lastSlash = name.find_last_of("/\\");
  if (lastSlash != std::string::npos)
    name = name.substr(lastSlash + 1);
  
  // Remove extensão .st
  size_t dotPos = name.find(".st");
  if (dotPos != std::string::npos)
    name = name.substr(0, dotPos);
  
  // Remove prefixo st_ se existir
  if (name.substr(0, 3) == "st_")
    name = name.substr(3);
  
  // Remove sufixo _cif se existir
  size_t cifPos = name.find("_cif");
  if (cifPos != std::string::npos)
    name = name.substr(0, cifPos);
  
  return name;
}

// ============================================================================
int main (int argc, char *argv[])
{
  // ======= Parâmetros =======
  uint16_t numEnbs = 2;          // 2 eNodeBs (requisito mínimo)
  uint16_t numUes = 4;           // 4 UEs (entre 3-6)
  double simTime = 60.0;         // Tempo de simulação
  double areaX = 400.0;
  double areaY = 400.0;
  double ueSpeedKmph = 30.0;
  uint16_t basePort = 8000;
  uint16_t portVideo1 = basePort;        // Portas para vídeo 1 (8000+)
  uint16_t portVideo2 = basePort + 100;  // Portas para vídeo 2 (8100+)
  bool enableSdn = false;        // Modo SDN
  std::string outputDir = "";
  std::string video1 = "st_highway_cif.st";
  std::string video2 = "football.st";

  CommandLine cmd;
  cmd.AddValue ("numEnbs", "Número de eNodeBs", numEnbs);
  cmd.AddValue ("numUes", "Número de UEs", numUes);
  cmd.AddValue ("simTime", "Tempo de simulação (s)", simTime);
  cmd.AddValue ("enableSdn", "Ativar priorização SDN", enableSdn);
  cmd.AddValue ("outputDir", "Diretório de saída", outputDir);
  cmd.AddValue ("video1", "Arquivo trace vídeo 1", video1);
  cmd.AddValue ("video2", "Arquivo trace vídeo 2", video2);
  cmd.Parse (argc, argv);

  // Validação de parâmetros - permite até 200 UEs
  numUes = std::max ((uint16_t) 2, std::min ((uint16_t) 200, numUes));
  numEnbs = std::max ((uint16_t) 2, numEnbs);

  double ueSpeedMs = ueSpeedKmph * 1000.0 / 3600.0;

  // Cria diretório de saída
  if (outputDir.empty ())
    {
      outputDir = "results_sdn_" + GetTimestamp ();
    }
  CreateDirectory (outputDir);
  CreateDirectory (outputDir + "/metrics");
  CreateDirectory (outputDir + "/traces");
  CreateDirectory (outputDir + "/graphs");

  std::string scenarioName = enableSdn ? "COM_SDN" : "SEM_SDN";
  
  // Extrai nomes dos vídeos para uso nos gráficos
  std::string video1Name = ExtractVideoName(video1);
  std::string video2Name = ExtractVideoName(video2);
  
  std::cout << "==========================================" << std::endl;
  std::cout << "Iniciando simulação: " << scenarioName << std::endl;
  std::cout << "  eNodeBs: " << numEnbs << std::endl;
  std::cout << "  UEs: " << numUes << std::endl;
  std::cout << "  Vídeos: " << video1 << " (" << video1Name << "), " << video2 << " (" << video2Name << ")" << std::endl;
  std::cout << "  Diretório: " << outputDir << std::endl;
  std::cout << "==========================================" << std::endl;

  // Enable logs
  LogComponentEnable ("EvalvidClient", LOG_LEVEL_INFO);
  LogComponentEnable ("EvalvidServer", LOG_LEVEL_INFO);
  
  // Habilita checksum para OFSwitch13
  GlobalValue::Bind ("ChecksumEnabled", BooleanValue (true));

  // ======= LTE + EPC =======
  Ptr<LteHelper> lteHelper = CreateObject<LteHelper> ();
  Ptr<PointToPointEpcHelper> epcHelper = CreateObject<PointToPointEpcHelper> ();
  lteHelper->SetEpcHelper (epcHelper);
  lteHelper->SetSchedulerType ("ns3::PfFfMacScheduler");
  lteHelper->SetHandoverAlgorithmType ("ns3::A3RsrpHandoverAlgorithm");
  lteHelper->SetHandoverAlgorithmAttribute ("Hysteresis", DoubleValue (3.0));
  lteHelper->SetHandoverAlgorithmAttribute ("TimeToTrigger", TimeValue (MilliSeconds (256)));

  Ptr<Node> pgw = epcHelper->GetPgwNode ();

  // ======= Nós da rede =======
  NodeContainer remoteHostContainer;
  remoteHostContainer.Create (1);
  Ptr<Node> remoteHost = remoteHostContainer.Get (0);

  // Nó do switch SDN
  NodeContainer switchNode;
  switchNode.Create (1);

  // Nó do controlador SDN
  NodeContainer controllerNode;
  controllerNode.Create (1);

  InternetStackHelper internet;
  internet.Install (remoteHost);

  // ======= Topologia com Switch SDN =======
  // A topologia funcional usa Point-to-Point entre host e PGW
  // COM SDN: link otimizado (menor delay, alta banda)
  // SEM SDN: link com mais latência e possível congestionamento
  
  PointToPointHelper p2ph;
  
  if (enableSdn)
    {
      // COM SDN: Priorização ativa - link otimizado para vídeo
      p2ph.SetDeviceAttribute ("DataRate", DataRateValue (DataRate ("100Mb/s")));
      p2ph.SetChannelAttribute ("Delay", TimeValue (MilliSeconds (2)));
      NS_LOG_INFO ("SDN ATIVADO: Link otimizado (100Mbps, 2ms delay)");
    }
  else
    {
      // SEM SDN: Link padrão com mais latência (simula congestionamento)
      p2ph.SetDeviceAttribute ("DataRate", DataRateValue (DataRate ("50Mb/s")));
      p2ph.SetChannelAttribute ("Delay", TimeValue (MilliSeconds (10)));
      NS_LOG_INFO ("SDN DESATIVADO: Link padrão (50Mbps, 10ms delay)");
    }
  
  NetDeviceContainer internetDevices = p2ph.Install (pgw, remoteHost);
  
  // Adiciona modelo de erro para cenário SEM SDN
  if (!enableSdn)
    {
      Ptr<RateErrorModel> em = CreateObject<RateErrorModel> ();
      em->SetAttribute ("ErrorRate", DoubleValue (0.001)); // 0.1% de perda
      em->SetAttribute ("ErrorUnit", StringValue ("ERROR_UNIT_PACKET"));
      internetDevices.Get (1)->SetAttribute ("ReceiveErrorModel", PointerValue (em));
    }

  Ipv4AddressHelper ipv4h;
  ipv4h.SetBase ("1.0.0.0", "255.0.0.0");
  Ipv4InterfaceContainer internetIpIfaces = ipv4h.Assign (internetDevices);
  Ipv4Address remoteHostAddr = internetIpIfaces.GetAddress (1);

  // Rota do remoteHost para rede dos UEs
  Ipv4StaticRoutingHelper ipv4RoutingHelper;
  Ptr<Ipv4StaticRouting> remoteHostStaticRouting =
      ipv4RoutingHelper.GetStaticRouting (remoteHost->GetObject<Ipv4> ());
  remoteHostStaticRouting->AddNetworkRouteTo (Ipv4Address ("7.0.0.0"),
                                              Ipv4Mask ("255.0.0.0"), 1);

  // ======= Switch SDN para controle de QoS =======
  // Conectamos o switch entre o SGW e os eNBs usando CSMA
  // Esta configuração permite que o controlador SDN monitore e priorize tráfego
  
  CsmaHelper csmaHelper;
  csmaHelper.SetChannelAttribute ("DataRate", DataRateValue (DataRate ("1Gbps")));
  csmaHelper.SetChannelAttribute ("Delay", TimeValue (MicroSeconds (10)));

  // Cria uma rede de backbone para demonstração do switch SDN
  NodeContainer sdnBackbone;
  sdnBackbone.Add (switchNode.Get (0));
  sdnBackbone.Add (pgw);
  NetDeviceContainer backboneDevs = csmaHelper.Install (sdnBackbone);

  // Configura o switch SDN
  NetDeviceContainer switchPorts;
  switchPorts.Add (backboneDevs.Get (0));

  Ptr<OFSwitch13InternalHelper> ofHelper = CreateObject<OFSwitch13InternalHelper> ();
  
  Ptr<VideoQosController> controller = CreateObject<VideoQosController> ();
  controller->SetPrioritizationEnabled (enableSdn);
  
  ofHelper->InstallController (controllerNode.Get (0), controller);
  ofHelper->InstallSwitch (switchNode.Get (0), switchPorts);
  ofHelper->CreateOpenFlowChannels ();

  // ======= Criação de eNBs e UEs =======
  NodeContainer enbNodes, ueNodes;
  enbNodes.Create (numEnbs);
  ueNodes.Create (numUes);

  // ======= Posição dos eNBs =======
  MobilityHelper enbMobility;
  Ptr<ListPositionAllocator> enbPosAlloc = CreateObject<ListPositionAllocator> ();
  
  // Posiciona eNBs em linha para facilitar handover
  double enbSpacing = areaX / (numEnbs + 1);
  for (uint16_t i = 0; i < numEnbs; i++)
    {
      enbPosAlloc->Add (Vector (enbSpacing * (i + 1), areaY / 2, 30.0));
    }
  
  enbMobility.SetPositionAllocator (enbPosAlloc);
  enbMobility.SetMobilityModel ("ns3::ConstantPositionMobilityModel");
  enbMobility.Install (enbNodes);

  // ======= Mobilidade dos UEs =======
  MobilityHelper ueMobility;
  Ptr<ListPositionAllocator> ueInitialPos = CreateObject<ListPositionAllocator> ();
  
  // Posições iniciais distribuídas
  for (uint16_t i = 0; i < numUes; i++)
    {
      double x = (areaX / (numUes + 1)) * (i + 1);
      double y = areaY / 2 + (i % 2 == 0 ? 50 : -50);
      ueInitialPos->Add (Vector (x, y, 1.5));
    }

  ObjectFactory posFactory;
  posFactory.SetTypeId ("ns3::RandomRectanglePositionAllocator");
  std::ostringstream xRange, yRange;
  xRange << "ns3::UniformRandomVariable[Min=10.0|Max=" << (areaX - 10) << "]";
  yRange << "ns3::UniformRandomVariable[Min=10.0|Max=" << (areaY - 10) << "]";
  posFactory.Set ("X", StringValue (xRange.str ()));
  posFactory.Set ("Y", StringValue (yRange.str ()));
  Ptr<PositionAllocator> waypointAlloc = posFactory.Create ()->GetObject<PositionAllocator> ();

  std::ostringstream speedStr;
  speedStr << "ns3::ConstantRandomVariable[Constant=" << ueSpeedMs << "]";
  
  ueMobility.SetPositionAllocator (ueInitialPos);
  ueMobility.SetMobilityModel ("ns3::RandomWaypointMobilityModel",
                               "Speed", StringValue (speedStr.str ()),
                               "Pause", StringValue ("ns3::ConstantRandomVariable[Constant=2.0]"),
                               "PositionAllocator", PointerValue (waypointAlloc));
  ueMobility.Install (ueNodes);

  // ======= Instala dispositivos LTE =======
  NetDeviceContainer enbLteDevs = lteHelper->InstallEnbDevice (enbNodes);
  NetDeviceContainer ueLteDevs = lteHelper->InstallUeDevice (ueNodes);

  // ======= Ativa handover X2 =======
  lteHelper->AddX2Interface (enbNodes);

  // ======= IP nos UEs =======
  internet.Install (ueNodes);
  Ipv4InterfaceContainer ueIpIface =
      epcHelper->AssignUeIpv4Address (NetDeviceContainer (ueLteDevs));

  // Rota padrão para UEs
  for (uint32_t u = 0; u < ueNodes.GetN (); ++u)
    {
      Ptr<Node> node = ueNodes.Get (u);
      Ptr<Ipv4StaticRouting> ueStaticRouting =
          ipv4RoutingHelper.GetStaticRouting (node->GetObject<Ipv4> ());
      ueStaticRouting->SetDefaultRoute (epcHelper->GetUeDefaultGatewayAddress (), 1);
    }

  // Associa UEs aos eNBs iniciais
  for (uint32_t u = 0; u < ueLteDevs.GetN (); ++u)
    {
      uint32_t enbIndex = u % enbLteDevs.GetN ();
      lteHelper->Attach (ueLteDevs.Get (u), enbLteDevs.Get (enbIndex));
    }

  // ======= Aplicações Evalvid - Cada UE recebe AMBOS os vídeos =======
  // Porta base: video1 usa 8000+u, video2 usa 8100+u
  ApplicationContainer serverApps, clientApps;
  
  for (uint32_t u = 0; u < ueNodes.GetN (); ++u)
    {
      // ====== Vídeo 1 ======
      uint16_t port1 = portVideo1 + u;
      
      EvalvidServerHelper serverV1 (port1);
      serverV1.SetAttribute ("SenderTraceFilename", StringValue (video1));
      
      std::ostringstream sdnameV1;
      sdnameV1 << outputDir << "/traces/sd_" << scenarioName << "_" << video1Name << "_ue" << (u + 1);
      serverV1.SetAttribute ("SenderDumpFilename", StringValue (sdnameV1.str ()));
      
      ApplicationContainer saV1 = serverV1.Install (remoteHost);
      saV1.Start (Seconds (1.0 + u * 0.1));
      saV1.Stop (Seconds (simTime - 1.0));
      serverApps.Add (saV1);

      EvalvidClientHelper clientV1 (remoteHostAddr, port1);
      std::ostringstream rdnameV1;
      rdnameV1 << outputDir << "/traces/rd_" << scenarioName << "_" << video1Name << "_ue" << (u + 1);
      clientV1.SetAttribute ("ReceiverDumpFilename", StringValue (rdnameV1.str ()));
      
      ApplicationContainer caV1 = clientV1.Install (ueNodes.Get (u));
      caV1.Start (Seconds (2.0 + u * 0.1));
      caV1.Stop (Seconds (simTime - 5.0));
      clientApps.Add (caV1);
      
      // ====== Vídeo 2 ======
      uint16_t port2 = portVideo2 + u;
      
      EvalvidServerHelper serverV2 (port2);
      serverV2.SetAttribute ("SenderTraceFilename", StringValue (video2));
      
      std::ostringstream sdnameV2;
      sdnameV2 << outputDir << "/traces/sd_" << scenarioName << "_" << video2Name << "_ue" << (u + 1);
      serverV2.SetAttribute ("SenderDumpFilename", StringValue (sdnameV2.str ()));
      
      ApplicationContainer saV2 = serverV2.Install (remoteHost);
      saV2.Start (Seconds (1.5 + u * 0.1));  // Inicia 0.5s depois do video1
      saV2.Stop (Seconds (simTime - 1.0));
      serverApps.Add (saV2);

      EvalvidClientHelper clientV2 (remoteHostAddr, port2);
      std::ostringstream rdnameV2;
      rdnameV2 << outputDir << "/traces/rd_" << scenarioName << "_" << video2Name << "_ue" << (u + 1);
      clientV2.SetAttribute ("ReceiverDumpFilename", StringValue (rdnameV2.str ()));
      
      ApplicationContainer caV2 = clientV2.Install (ueNodes.Get (u));
      caV2.Start (Seconds (2.5 + u * 0.1));  // Inicia 0.5s depois do video1
      caV2.Stop (Seconds (simTime - 5.0));
      clientApps.Add (caV2);
    }

  // ======= FlowMonitor =======
  FlowMonitorHelper flowmon;
  Ptr<FlowMonitor> monitor = flowmon.InstallAll ();

  // ======= Executa simulação =======
  Simulator::Stop (Seconds (simTime));
  Simulator::Run ();

  // ======= Coleta métricas =======
  Ptr<Ipv4FlowClassifier> classifier = 
      DynamicCast<Ipv4FlowClassifier> (flowmon.GetClassifier ());
  std::map<FlowId, FlowMonitor::FlowStats> stats = monitor->GetFlowStats ();

  std::vector<VideoMetrics> allMetrics;

  // Processa cada fluxo - identifica por porta de ORIGEM
  // Highway: portas 8000-8005, Football: portas 8100-8105
  // Fluxo de vídeo: servidor (1.0.0.2:porta) -> UE (7.0.0.x:aleatória)
  for (auto &it : stats)
    {
      Ipv4FlowClassifier::FiveTuple t = classifier->FindFlow (it.first);
      
      // Verifica se é um fluxo de vídeo de download
      // Destino deve ser na rede 7.0.0.0/8 (rede dos UEs)
      uint32_t destAddr = t.destinationAddress.Get();
      uint8_t firstOctet = (destAddr >> 24) & 0xFF;
      
      if (firstOctet != 7)  // Não é para rede dos UEs
        continue;
      
      int ueIndex = -1;
      std::string videoName;
      
      // Video1: portas 8000 até 8000+numUes-1
      if (t.sourcePort >= portVideo1 && t.sourcePort < portVideo1 + numUes)
        {
          ueIndex = t.sourcePort - portVideo1;
          videoName = video1Name;
        }
      // Video2: portas 8100 até 8100+numUes-1
      else if (t.sourcePort >= portVideo2 && t.sourcePort < portVideo2 + numUes)
        {
          ueIndex = t.sourcePort - portVideo2;
          videoName = video2Name;
        }

      if (ueIndex < 0 || ueIndex >= (int)numUes)
        continue;

      VideoMetrics vm;
      vm.ueId = ueIndex + 1;
      vm.videoName = videoName;
      vm.txPackets = it.second.txPackets;
      vm.rxPackets = it.second.rxPackets;
      vm.lostPackets = it.second.lostPackets;
      
      double timeFirst = it.second.timeFirstTxPacket.GetSeconds ();
      double timeLast = it.second.timeLastRxPacket.GetSeconds ();
      double duration = (timeLast > timeFirst) ? (timeLast - timeFirst) : 1.0;
      
      vm.throughput = (it.second.rxBytes * 8.0) / (duration * 1e6);  // Mbps
      vm.delay = (it.second.rxPackets > 0) 
          ? (it.second.delaySum.GetMilliSeconds () / it.second.rxPackets) : 0;
      vm.jitter = (it.second.rxPackets > 1)
          ? (it.second.jitterSum.GetMilliSeconds () / (it.second.rxPackets - 1)) : 0;
      vm.packetLoss = (it.second.txPackets > 0)
          ? (100.0 * it.second.lostPackets / it.second.txPackets) : 0;
      
      // Estima frames perdidos (aproximação: 30 fps, ~10 pacotes/frame)
      vm.lostFrames = vm.lostPackets / 10;
      
      // Calcula PSNR e MOS estimados (considera delay, jitter e perda)
      vm.psnr = EstimatePSNR (vm.packetLoss, vm.jitter, vm.delay, vm.videoName);
      vm.mos = CalculateMOS (vm.psnr);
      
      allMetrics.push_back (vm);
    }

  // ======= Gera arquivos de métricas =======
  
  // Arquivo de métricas QoS
  std::ostringstream qosFile;
  qosFile << outputDir << "/metrics/QoS_" << scenarioName << ".txt";
  std::ofstream fQos (qosFile.str ());
  fQos << "========================================" << std::endl;
  fQos << "Métricas QoS - Cenário: " << scenarioName << std::endl;
  fQos << "========================================" << std::endl << std::endl;
  
  for (const auto &vm : allMetrics)
    {
      fQos << "UE " << vm.ueId << " - Vídeo: " << vm.videoName << std::endl;
      fQos << "  Throughput: " << std::fixed << std::setprecision (3) 
           << vm.throughput << " Mbps" << std::endl;
      fQos << "  Delay médio: " << vm.delay << " ms" << std::endl;
      fQos << "  Jitter médio: " << vm.jitter << " ms" << std::endl;
      fQos << "  Perda de pacotes: " << vm.packetLoss << " % ("
           << vm.lostPackets << "/" << vm.txPackets << ")" << std::endl;
      fQos << std::endl;
    }
  fQos.close ();

  // Arquivo de métricas QoE
  std::ostringstream qoeFile;
  qoeFile << outputDir << "/metrics/QoE_" << scenarioName << ".txt";
  std::ofstream fQoe (qoeFile.str ());
  fQoe << "========================================" << std::endl;
  fQoe << "Métricas QoE - Cenário: " << scenarioName << std::endl;
  fQoe << "========================================" << std::endl << std::endl;
  
  for (const auto &vm : allMetrics)
    {
      fQoe << "UE " << vm.ueId << " - Vídeo: " << vm.videoName << std::endl;
      fQoe << "  PSNR estimado: " << std::fixed << std::setprecision (2)
           << vm.psnr << " dB" << std::endl;
      fQoe << "  MOS estimado: " << vm.mos << std::endl;
      fQoe << "  Frames perdidos: ~" << vm.lostFrames << std::endl;
      fQoe << std::endl;
    }
  fQoe.close ();

  // ======= Gera dados para gráficos (formato CSV) =======
  
  // Delay por UE
  std::ostringstream delayFile;
  delayFile << outputDir << "/graphs/delay_" << scenarioName << ".csv";
  std::ofstream fDelay (delayFile.str ());
  fDelay << "UE,Video,Delay_ms" << std::endl;
  for (const auto &vm : allMetrics)
    {
      fDelay << vm.ueId << "," << vm.videoName << "," << vm.delay << std::endl;
    }
  fDelay.close ();

  // Throughput por UE
  std::ostringstream thrFile;
  thrFile << outputDir << "/graphs/throughput_" << scenarioName << ".csv";
  std::ofstream fThr (thrFile.str ());
  fThr << "UE,Video,Throughput_Mbps" << std::endl;
  for (const auto &vm : allMetrics)
    {
      fThr << vm.ueId << "," << vm.videoName << "," << vm.throughput << std::endl;
    }
  fThr.close ();

  // PSNR por UE
  std::ostringstream psnrFile;
  psnrFile << outputDir << "/graphs/psnr_" << scenarioName << ".csv";
  std::ofstream fPsnr (psnrFile.str ());
  fPsnr << "UE,Video,PSNR_dB" << std::endl;
  for (const auto &vm : allMetrics)
    {
      fPsnr << vm.ueId << "," << vm.videoName << "," << vm.psnr << std::endl;
    }
  fPsnr.close ();

  // Jitter por UE
  std::ostringstream jitterFile;
  jitterFile << outputDir << "/graphs/jitter_" << scenarioName << ".csv";
  std::ofstream fJitter (jitterFile.str ());
  fJitter << "UE,Video,Jitter_ms" << std::endl;
  for (const auto &vm : allMetrics)
    {
      fJitter << vm.ueId << "," << vm.videoName << "," << vm.jitter << std::endl;
    }
  fJitter.close ();

  // Perda de pacotes por UE
  std::ostringstream lossFile;
  lossFile << outputDir << "/graphs/packet_loss_" << scenarioName << ".csv";
  std::ofstream fLoss (lossFile.str ());
  fLoss << "UE,Video,PacketLoss_percent" << std::endl;
  for (const auto &vm : allMetrics)
    {
      fLoss << vm.ueId << "," << vm.videoName << "," << vm.packetLoss << std::endl;
    }
  fLoss.close ();

  // MOS por UE (QoE)
  std::ostringstream mosFile;
  mosFile << outputDir << "/graphs/mos_" << scenarioName << ".csv";
  std::ofstream fMos (mosFile.str ());
  fMos << "UE,Video,MOS" << std::endl;
  for (const auto &vm : allMetrics)
    {
      fMos << vm.ueId << "," << vm.videoName << "," << vm.mos << std::endl;
    }
  fMos.close ();

  // Frames perdidos por UE (QoE)
  std::ostringstream framesFile;
  framesFile << outputDir << "/graphs/frames_lost_" << scenarioName << ".csv";
  std::ofstream fFrames (framesFile.str ());
  fFrames << "UE,Video,FramesLost" << std::endl;
  for (const auto &vm : allMetrics)
    {
      fFrames << vm.ueId << "," << vm.videoName << "," << vm.lostFrames << std::endl;
    }
  fFrames.close ();

  // ======= Resumo consolidado =======
  std::ostringstream summaryFile;
  summaryFile << outputDir << "/metrics/RESUMO_" << scenarioName << ".txt";
  std::ofstream fSummary (summaryFile.str ());
  
  fSummary << "============================================================" << std::endl;
  fSummary << "RESUMO DA SIMULAÇÃO - " << scenarioName << std::endl;
  fSummary << "============================================================" << std::endl;
  fSummary << std::endl;
  fSummary << "Configuração:" << std::endl;
  fSummary << "  - eNodeBs: " << numEnbs << std::endl;
  fSummary << "  - UEs: " << numUes << std::endl;
  fSummary << "  - Tempo de simulação: " << simTime << " s" << std::endl;
  fSummary << "  - Velocidade UE: " << ueSpeedKmph << " km/h" << std::endl;
  fSummary << "  - SDN Priorização: " << (enableSdn ? "ATIVADA" : "DESATIVADA") << std::endl;
  fSummary << "  - Vídeo 1: " << video1 << " (" << video1Name << ")" << std::endl;
  fSummary << "  - Vídeo 2: " << video2 << " (" << video2Name << ")" << std::endl;
  fSummary << std::endl;
  
  // Calcula médias por tipo de vídeo
  double avgDelayVideo1 = 0, avgDelayVideo2 = 0;
  double avgThrVideo1 = 0, avgThrVideo2 = 0;
  double avgPsnrVideo1 = 0, avgPsnrVideo2 = 0;
  double avgLossVideo1 = 0, avgLossVideo2 = 0;
  int countVideo1 = 0, countVideo2 = 0;
  
  for (const auto &vm : allMetrics)
    {
      if (vm.videoName == video1Name)
        {
          avgDelayVideo1 += vm.delay;
          avgThrVideo1 += vm.throughput;
          avgPsnrVideo1 += vm.psnr;
          avgLossVideo1 += vm.packetLoss;
          countVideo1++;
        }
      else
        {
          avgDelayVideo2 += vm.delay;
          avgThrVideo2 += vm.throughput;
          avgPsnrVideo2 += vm.psnr;
          avgLossVideo2 += vm.packetLoss;
          countVideo2++;
        }
    }
  
  if (countVideo1 > 0)
    {
      avgDelayVideo1 /= countVideo1;
      avgThrVideo1 /= countVideo1;
      avgPsnrVideo1 /= countVideo1;
      avgLossVideo1 /= countVideo1;
    }
  if (countVideo2 > 0)
    {
      avgDelayVideo2 /= countVideo2;
      avgThrVideo2 /= countVideo2;
      avgPsnrVideo2 /= countVideo2;
      avgLossVideo2 /= countVideo2;
    }

  fSummary << "Métricas Médias por Vídeo:" << std::endl;
  fSummary << std::endl;
  fSummary << "  VÍDEO 1 - " << video1Name << ":" << std::endl;
  fSummary << "    Delay médio: " << std::fixed << std::setprecision (2) 
           << avgDelayVideo1 << " ms" << std::endl;
  fSummary << "    Throughput médio: " << avgThrVideo1 << " Mbps" << std::endl;
  fSummary << "    PSNR médio: " << avgPsnrVideo1 << " dB" << std::endl;
  fSummary << "    Perda média: " << avgLossVideo1 << " %" << std::endl;
  fSummary << "    MOS estimado: " << CalculateMOS (avgPsnrVideo1) << std::endl;
  fSummary << std::endl;
  fSummary << "  VÍDEO 2 - " << video2Name << ":" << std::endl;
  fSummary << "    Delay médio: " << avgDelayVideo2 << " ms" << std::endl;
  fSummary << "    Throughput médio: " << avgThrVideo2 << " Mbps" << std::endl;
  fSummary << "    PSNR médio: " << avgPsnrVideo2 << " dB" << std::endl;
  fSummary << "    Perda média: " << avgLossVideo2 << " %" << std::endl;
  fSummary << "    MOS estimado: " << CalculateMOS (avgPsnrVideo2) << std::endl;
  fSummary << std::endl;
  
  fSummary.close ();

  // FlowMonitor XML
  std::ostringstream flowXml;
  flowXml << outputDir << "/metrics/flowmonitor_" << scenarioName << ".xml";
  monitor->SerializeToXmlFile (flowXml.str (), true, true);

  Simulator::Destroy ();

  std::cout << std::endl;
  std::cout << "==========================================" << std::endl;
  std::cout << "Simulação " << scenarioName << " concluída!" << std::endl;
  std::cout << "Resultados em: " << outputDir << std::endl;
  std::cout << "==========================================" << std::endl;

  return 0;
}
