/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */
/*
 * Controlador SDN para priorização de fluxo de vídeo (EvalVid)
 * Implementa regras OpenFlow para QoS em streaming de vídeo sobre LTE
 */

#include "video-qos-controller.h"

#include <ns3/internet-module.h>
#include <ns3/network-module.h>

namespace ns3 {

NS_LOG_COMPONENT_DEFINE ("VideoQosController");
NS_OBJECT_ENSURE_REGISTERED (VideoQosController);

VideoQosController::VideoQosController ()
{
  NS_LOG_FUNCTION (this);
}

VideoQosController::~VideoQosController ()
{
  NS_LOG_FUNCTION (this);
}

void
VideoQosController::DoDispose ()
{
  NS_LOG_FUNCTION (this);
  m_arpTable.clear ();
  OFSwitch13Controller::DoDispose ();
}

TypeId
VideoQosController::GetTypeId ()
{
  static TypeId tid = TypeId ("ns3::VideoQosController")
    .SetParent<OFSwitch13Controller> ()
    .SetGroupName ("OFSwitch13")
    .AddConstructor<VideoQosController> ()
    .AddAttribute ("EnableQos",
                   "Enable QoS prioritization for video flows.",
                   BooleanValue (true),
                   MakeBooleanAccessor (&VideoQosController::m_enableQos),
                   MakeBooleanChecker ())
    .AddAttribute ("EnableMeter",
                   "Enable per-flow metering.",
                   BooleanValue (false),
                   MakeBooleanAccessor (&VideoQosController::m_enableMeter),
                   MakeBooleanChecker ())
    .AddAttribute ("VideoMeterRate",
                   "Video flow meter rate.",
                   DataRateValue (DataRate ("10Mbps")),
                   MakeDataRateAccessor (&VideoQosController::m_videoMeterRate),
                   MakeDataRateChecker ())
    .AddAttribute ("VideoPortStart",
                   "Start port for video flows (EvalVid).",
                   UintegerValue (8000),
                   MakeUintegerAccessor (&VideoQosController::m_videoPortStart),
                   MakeUintegerChecker<uint16_t> ())
    .AddAttribute ("VideoPortEnd",
                   "End port for video flows (EvalVid).",
                   UintegerValue (8100),
                   MakeUintegerAccessor (&VideoQosController::m_videoPortEnd),
                   MakeUintegerChecker<uint16_t> ());
  return tid;
}

void
VideoQosController::HandshakeSuccessful (Ptr<const RemoteSwitch> swtch)
{
  NS_LOG_FUNCTION (this << swtch);
  NS_LOG_INFO ("Handshake successful with switch " << swtch->GetDpId ());
  
  // Configure switch after successful handshake
  ConfigureSwitch (swtch);
}

void
VideoQosController::ConfigureSwitch (Ptr<const RemoteSwitch> swtch)
{
  NS_LOG_FUNCTION (this << swtch);
  
  uint64_t dpId = swtch->GetDpId ();
  
  // Set miss send length for packet-in messages
  DpctlExecute (dpId, "set-config miss=128");
  
  // ============= REGRAS DE APRENDIZADO BÁSICO =============
  
  // Redireciona requisições ARP para o controlador
  DpctlExecute (dpId,
                "flow-mod cmd=add,table=0,prio=100 "
                "eth_type=0x0806 apply:output=ctrl");
  
  // Regra padrão: encaminha para todas as portas (flood) - prioridade baixa
  DpctlExecute (dpId,
                "flow-mod cmd=add,table=0,prio=1 "
                "apply:output=flood");

  if (m_enableQos)
    {
      NS_LOG_INFO ("Configurando QoS para fluxos de vídeo no switch " << dpId);
      
      // ============= REGRAS DE PRIORIZAÇÃO DE VÍDEO (UDP) =============
      
      // Cria fila de alta prioridade (queue 0 = alta prioridade)
      // Nota: OpenFlow 1.3 usa set_queue para direcionar para filas específicas
      
      // Configura meter para controle de banda (opcional)
      if (m_enableMeter)
        {
          // Cria meter com rate limiting para fluxo de vídeo
          std::ostringstream meterCmd;
          uint64_t rateKbps = m_videoMeterRate.GetBitRate () / 1000;
          meterCmd << "meter-mod cmd=add,flags=1,meter=1 "
                   << "drop:rate=" << rateKbps;
          DpctlExecute (dpId, meterCmd.str ());
        }
      
      // Regra de alta prioridade para tráfego UDP na faixa de portas do EvalVid
      // Prioriza tráfego de vídeo (portas 8000-8100) com alta prioridade
      for (uint16_t port = m_videoPortStart; port <= m_videoPortEnd; port++)
        {
          std::ostringstream cmdSrc, cmdDst;
          
          // Prioriza tráfego UDP com porta de origem na faixa de vídeo
          cmdSrc << "flow-mod cmd=add,table=0,prio=1000 "
                 << "eth_type=0x0800,ip_proto=17,udp_src=" << port
                 << " apply:output=flood";
          DpctlExecute (dpId, cmdSrc.str ());
          
          // Prioriza tráfego UDP com porta de destino na faixa de vídeo
          cmdDst << "flow-mod cmd=add,table=0,prio=1000 "
                 << "eth_type=0x0800,ip_proto=17,udp_dst=" << port
                 << " apply:output=flood";
          DpctlExecute (dpId, cmdDst.str ());
        }
      
      // Regra genérica para TODO tráfego UDP (EvalVid usa UDP)
      // Prioridade intermediária para garantir preferência sobre tráfego genérico
      DpctlExecute (dpId,
                    "flow-mod cmd=add,table=0,prio=500 "
                    "eth_type=0x0800,ip_proto=17 apply:output=flood");
      
      // Tráfego IP genérico (TCP e outros) - prioridade mais baixa que vídeo
      DpctlExecute (dpId,
                    "flow-mod cmd=add,table=0,prio=200 "
                    "eth_type=0x0800 apply:output=flood");
      
      NS_LOG_INFO ("Regras de QoS configuradas para portas " 
                   << m_videoPortStart << "-" << m_videoPortEnd);
    }
  else
    {
      NS_LOG_INFO ("Switch " << dpId << " configurado como learning switch (sem QoS)");
      
      // Sem QoS: apenas encaminha todo tráfego IP normalmente
      DpctlExecute (dpId,
                    "flow-mod cmd=add,table=0,prio=200 "
                    "eth_type=0x0800 apply:output=flood");
    }
}

ofl_err
VideoQosController::HandlePacketIn (struct ofl_msg_packet_in *msg,
                                     Ptr<const RemoteSwitch> swtch,
                                     uint32_t xid)
{
  NS_LOG_FUNCTION (this << swtch << xid);
  
  char *msgStr = ofl_structs_match_to_string ((struct ofl_match_header*)msg->match, nullptr);
  NS_LOG_DEBUG ("Packet in match: " << msgStr);
  free (msgStr);
  
  // Get Ethernet frame type
  uint16_t ethType;
  struct ofl_match_tlv *tlv;
  tlv = oxm_match_lookup (OXM_OF_ETH_TYPE, (struct ofl_match*)msg->match);
  memcpy (&ethType, tlv->value, OXM_LENGTH (OXM_OF_ETH_TYPE));
  
  if (ethType == ArpL3Protocol::PROT_NUMBER)
    {
      // Handle ARP packet
      return HandleArpPacketIn (msg, swtch, xid);
    }
  
  // Free the message when done
  ofl_msg_free ((struct ofl_msg_header*)msg, nullptr);
  return 0;
}

ofl_err
VideoQosController::HandleArpPacketIn (struct ofl_msg_packet_in *msg,
                                        Ptr<const RemoteSwitch> swtch,
                                        uint32_t xid)
{
  NS_LOG_FUNCTION (this << swtch << xid);
  
  struct ofl_match *match = (struct ofl_match*)msg->match;
  
  // Get ARP operation
  uint16_t arpOp;
  struct ofl_match_tlv *tlv;
  tlv = oxm_match_lookup (OXM_OF_ARP_OP, match);
  memcpy (&arpOp, tlv->value, OXM_LENGTH (OXM_OF_ARP_OP));
  
  // Get source IP and MAC addresses
  Ipv4Address srcIp = ExtractIpv4Address (OXM_OF_ARP_SPA, match);
  tlv = oxm_match_lookup (OXM_OF_ARP_SHA, match);
  Mac48Address srcMac;
  srcMac.CopyFrom (tlv->value);
  
  // Save ARP entry
  SaveArpEntry (srcIp, srcMac);
  
  // Get input port
  uint32_t inPort;
  tlv = oxm_match_lookup (OXM_OF_IN_PORT, match);
  memcpy (&inPort, tlv->value, OXM_LENGTH (OXM_OF_IN_PORT));
  
  // For ARP requests, flood to all ports
  if (arpOp == 1) // ARP Request
    {
      // Create packet out to flood
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
      
      // Create flood action
      struct ofl_action_output *actOut = (struct ofl_action_output*)
          xmalloc (sizeof (struct ofl_action_output));
      actOut->header.type = OFPAT_OUTPUT;
      actOut->port = OFPP_FLOOD;
      actOut->max_len = 0;
      
      reply.actions_num = 1;
      reply.actions = (struct ofl_action_header**)&actOut;
      
      SendToSwitch (swtch, (struct ofl_msg_header*)&reply, xid);
      free (actOut);
    }
  
  // Free the message
  ofl_msg_free ((struct ofl_msg_header*)msg, nullptr);
  return 0;
}

Ipv4Address
VideoQosController::ExtractIpv4Address (uint32_t oxm_of, struct ofl_match *match)
{
  switch (oxm_of)
    {
    case OXM_OF_ARP_SPA:
    case OXM_OF_ARP_TPA:
    case OXM_OF_IPV4_SRC:
    case OXM_OF_IPV4_DST:
      {
        uint32_t ip;
        struct ofl_match_tlv *tlv = oxm_match_lookup (oxm_of, match);
        memcpy (&ip, tlv->value, OXM_LENGTH (oxm_of));
        return Ipv4Address (ntohl (ip));
      }
    default:
      NS_ABORT_MSG ("Invalid IP OXM field");
    }
}

void
VideoQosController::SaveArpEntry (Ipv4Address ipAddr, Mac48Address macAddr)
{
  NS_LOG_FUNCTION (this << ipAddr << macAddr);
  m_arpTable[ipAddr] = macAddr;
}

Mac48Address
VideoQosController::GetArpEntry (Ipv4Address ipAddr)
{
  NS_LOG_FUNCTION (this << ipAddr);
  auto it = m_arpTable.find (ipAddr);
  if (it != m_arpTable.end ())
    {
      return it->second;
    }
  return Mac48Address ();
}

} // namespace ns3
