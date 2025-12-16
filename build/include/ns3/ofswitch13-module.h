#ifdef NS3_MODULE_COMPILATION 
    error "Do not include ns3 module aggregator headers from other modules these are meant only for end user scripts." 
#endif 
#ifndef NS3_MODULE_OFSWITCH13
    // Module headers: 
    #include <ns3/ofswitch13-controller.h>
    #include <ns3/ofswitch13-device.h>
    #include <ns3/ofswitch13-interface.h>
    #include <ns3/ofswitch13-learning-controller.h>
    #include <ns3/ofswitch13-queue.h>
    #include <ns3/ofswitch13-priority-queue.h>
    #include <ns3/ofswitch13-port.h>
    #include <ns3/ofswitch13-socket-handler.h>
    #include <ns3/queue-tag.h>
    #include <ns3/tunnel-id-tag.h>
    #include <ns3/ofswitch13-device-container.h>
    #include <ns3/ofswitch13-external-helper.h>
    #include <ns3/ofswitch13-helper.h>
    #include <ns3/ofswitch13-internal-helper.h>
    #include <ns3/ofswitch13-stats-calculator.h>
#endif 