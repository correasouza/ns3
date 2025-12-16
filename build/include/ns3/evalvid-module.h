#ifdef NS3_MODULE_COMPILATION 
    error "Do not include ns3 module aggregator headers from other modules these are meant only for end user scripts." 
#endif 
#ifndef NS3_MODULE_EVALVID
    // Module headers: 
    #include <ns3/evalvid-client.h>
    #include <ns3/evalvid-server.h>
    #include <ns3/evalvid-client-server-helper.h>
#endif 