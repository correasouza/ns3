/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */
/*
 * Controlador SDN para priorização de fluxo de vídeo (EvalVid)
 * Implementa regras OpenFlow para QoS em streaming de vídeo sobre LTE
 */

#ifndef VIDEO_QOS_CONTROLLER_H
#define VIDEO_QOS_CONTROLLER_H

// STL headers (devem vir antes do ofswitch13 para evitar conflito com bofuss/list.h)
#include <map>
#include <string>

#include <ns3/ofswitch13-module.h>

namespace ns3 {

/**
 * \brief Controlador OpenFlow 1.3 para priorização de vídeo
 * 
 * Este controlador implementa:
 * - Learning switch básico para tráfego normal
 * - Priorização de fluxos UDP (vídeo EvalVid) usando meters
 * - Filas de QoS para garantir largura de banda mínima para vídeo
 */
class VideoQosController : public OFSwitch13Controller
{
public:
  VideoQosController ();
  ~VideoQosController () override;

  /** Destructor implementation */
  void DoDispose () override;

  /**
   * Register this type.
   * \return The object TypeId.
   */
  static TypeId GetTypeId ();

  /**
   * Handle a packet in message sent by the switch to this controller.
   * \param msg The OpenFlow received message.
   * \param swtch The remote switch metadata.
   * \param xid The transaction id from the request message.
   * \return 0 if everything's ok, otherwise an error number.
   */
  ofl_err HandlePacketIn (struct ofl_msg_packet_in *msg,
                          Ptr<const RemoteSwitch> swtch,
                          uint32_t xid) override;

protected:
  // Inherited from OFSwitch13Controller
  void HandshakeSuccessful (Ptr<const RemoteSwitch> swtch) override;

private:
  /**
   * Configure as regras do switch para priorização de vídeo.
   * \param swtch The switch information.
   */
  void ConfigureSwitch (Ptr<const RemoteSwitch> swtch);

  /**
   * Handle ARP request messages.
   * \param msg The packet-in message.
   * \param swtch The switch information.
   * \param xid Transaction id.
   * \return 0 if everything's ok, otherwise an error number.
   */
  ofl_err HandleArpPacketIn (struct ofl_msg_packet_in *msg,
                             Ptr<const RemoteSwitch> swtch,
                             uint32_t xid);

  /**
   * Extract an IPv4 address from packet match.
   * \param oxm_of The OXM_IF_* IPv4 field.
   * \param match The ofl_match structure pointer.
   * \return The IPv4 address.
   */
  Ipv4Address ExtractIpv4Address (uint32_t oxm_of, struct ofl_match *match);

  /**
   * Save the pair IP / MAC address in ARP table.
   * \param ipAddr The IPv4 address.
   * \param macAddr The MAC address.
   */
  void SaveArpEntry (Ipv4Address ipAddr, Mac48Address macAddr);

  /**
   * Lookup for a MAC address in ARP table.
   * \param ipAddr The IPv4 address.
   * \return The MAC address.
   */
  Mac48Address GetArpEntry (Ipv4Address ipAddr);

  bool m_enableQos;                                 //!< Enable QoS prioritization
  bool m_enableMeter;                               //!< Enable metering
  DataRate m_videoMeterRate;                        //!< Video meter rate
  uint16_t m_videoPortStart;                        //!< Start port for video
  uint16_t m_videoPortEnd;                          //!< End port for video
  std::map<Ipv4Address, Mac48Address> m_arpTable;   //!< ARP table
};

} // namespace ns3

#endif /* VIDEO_QOS_CONTROLLER_H */
