# Install script for directory: /usr/ns-3-dev/src/internet

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set path to fallback-tool for dependency-resolution.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-internet-optimized.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-internet-optimized.so")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-internet-optimized.so"
         RPATH "/usr/local/lib:$ORIGIN/:$ORIGIN/../lib")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/usr/ns-3-dev/build/lib/libns3.39-internet-optimized.so")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-internet-optimized.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-internet-optimized.so")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-internet-optimized.so"
         OLD_RPATH "/usr/ns-3-dev/build/lib:::::::::::::::"
         NEW_RPATH "/usr/local/lib:$ORIGIN/:$ORIGIN/../lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-internet-optimized.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/ns3" TYPE FILE FILES
    "/usr/ns-3-dev/src/internet/helper/internet-stack-helper.h"
    "/usr/ns-3-dev/src/internet/helper/internet-trace-helper.h"
    "/usr/ns-3-dev/src/internet/helper/ipv4-address-helper.h"
    "/usr/ns-3-dev/src/internet/helper/ipv4-global-routing-helper.h"
    "/usr/ns-3-dev/src/internet/helper/ipv4-interface-container.h"
    "/usr/ns-3-dev/src/internet/helper/ipv4-list-routing-helper.h"
    "/usr/ns-3-dev/src/internet/helper/ipv4-routing-helper.h"
    "/usr/ns-3-dev/src/internet/helper/ipv4-static-routing-helper.h"
    "/usr/ns-3-dev/src/internet/helper/ipv6-address-helper.h"
    "/usr/ns-3-dev/src/internet/helper/ipv6-interface-container.h"
    "/usr/ns-3-dev/src/internet/helper/ipv6-list-routing-helper.h"
    "/usr/ns-3-dev/src/internet/helper/ipv6-routing-helper.h"
    "/usr/ns-3-dev/src/internet/helper/ipv6-static-routing-helper.h"
    "/usr/ns-3-dev/src/internet/helper/neighbor-cache-helper.h"
    "/usr/ns-3-dev/src/internet/helper/rip-helper.h"
    "/usr/ns-3-dev/src/internet/helper/ripng-helper.h"
    "/usr/ns-3-dev/src/internet/model/arp-cache.h"
    "/usr/ns-3-dev/src/internet/model/arp-header.h"
    "/usr/ns-3-dev/src/internet/model/arp-l3-protocol.h"
    "/usr/ns-3-dev/src/internet/model/arp-queue-disc-item.h"
    "/usr/ns-3-dev/src/internet/model/candidate-queue.h"
    "/usr/ns-3-dev/src/internet/model/global-route-manager-impl.h"
    "/usr/ns-3-dev/src/internet/model/global-route-manager.h"
    "/usr/ns-3-dev/src/internet/model/global-router-interface.h"
    "/usr/ns-3-dev/src/internet/model/icmpv4-l4-protocol.h"
    "/usr/ns-3-dev/src/internet/model/icmpv4.h"
    "/usr/ns-3-dev/src/internet/model/icmpv6-header.h"
    "/usr/ns-3-dev/src/internet/model/icmpv6-l4-protocol.h"
    "/usr/ns-3-dev/src/internet/model/ip-l4-protocol.h"
    "/usr/ns-3-dev/src/internet/model/ipv4-address-generator.h"
    "/usr/ns-3-dev/src/internet/model/ipv4-end-point-demux.h"
    "/usr/ns-3-dev/src/internet/model/ipv4-end-point.h"
    "/usr/ns-3-dev/src/internet/model/ipv4-global-routing.h"
    "/usr/ns-3-dev/src/internet/model/ipv4-header.h"
    "/usr/ns-3-dev/src/internet/model/ipv4-interface-address.h"
    "/usr/ns-3-dev/src/internet/model/ipv4-interface.h"
    "/usr/ns-3-dev/src/internet/model/ipv4-l3-protocol.h"
    "/usr/ns-3-dev/src/internet/model/ipv4-list-routing.h"
    "/usr/ns-3-dev/src/internet/model/ipv4-packet-filter.h"
    "/usr/ns-3-dev/src/internet/model/ipv4-packet-info-tag.h"
    "/usr/ns-3-dev/src/internet/model/ipv4-packet-probe.h"
    "/usr/ns-3-dev/src/internet/model/ipv4-queue-disc-item.h"
    "/usr/ns-3-dev/src/internet/model/ipv4-raw-socket-factory.h"
    "/usr/ns-3-dev/src/internet/model/ipv4-raw-socket-impl.h"
    "/usr/ns-3-dev/src/internet/model/ipv4-route.h"
    "/usr/ns-3-dev/src/internet/model/ipv4-routing-protocol.h"
    "/usr/ns-3-dev/src/internet/model/ipv4-routing-table-entry.h"
    "/usr/ns-3-dev/src/internet/model/ipv4-static-routing.h"
    "/usr/ns-3-dev/src/internet/model/ipv4.h"
    "/usr/ns-3-dev/src/internet/model/ipv6-address-generator.h"
    "/usr/ns-3-dev/src/internet/model/ipv6-end-point-demux.h"
    "/usr/ns-3-dev/src/internet/model/ipv6-end-point.h"
    "/usr/ns-3-dev/src/internet/model/ipv6-extension-demux.h"
    "/usr/ns-3-dev/src/internet/model/ipv6-extension-header.h"
    "/usr/ns-3-dev/src/internet/model/ipv6-extension.h"
    "/usr/ns-3-dev/src/internet/model/ipv6-header.h"
    "/usr/ns-3-dev/src/internet/model/ipv6-interface-address.h"
    "/usr/ns-3-dev/src/internet/model/ipv6-interface.h"
    "/usr/ns-3-dev/src/internet/model/ipv6-l3-protocol.h"
    "/usr/ns-3-dev/src/internet/model/ipv6-list-routing.h"
    "/usr/ns-3-dev/src/internet/model/ipv6-option-header.h"
    "/usr/ns-3-dev/src/internet/model/ipv6-option.h"
    "/usr/ns-3-dev/src/internet/model/ipv6-packet-filter.h"
    "/usr/ns-3-dev/src/internet/model/ipv6-packet-info-tag.h"
    "/usr/ns-3-dev/src/internet/model/ipv6-packet-probe.h"
    "/usr/ns-3-dev/src/internet/model/ipv6-pmtu-cache.h"
    "/usr/ns-3-dev/src/internet/model/ipv6-queue-disc-item.h"
    "/usr/ns-3-dev/src/internet/model/ipv6-raw-socket-factory.h"
    "/usr/ns-3-dev/src/internet/model/ipv6-route.h"
    "/usr/ns-3-dev/src/internet/model/ipv6-routing-protocol.h"
    "/usr/ns-3-dev/src/internet/model/ipv6-routing-table-entry.h"
    "/usr/ns-3-dev/src/internet/model/ipv6-static-routing.h"
    "/usr/ns-3-dev/src/internet/model/ipv6.h"
    "/usr/ns-3-dev/src/internet/model/loopback-net-device.h"
    "/usr/ns-3-dev/src/internet/model/ndisc-cache.h"
    "/usr/ns-3-dev/src/internet/model/rip-header.h"
    "/usr/ns-3-dev/src/internet/model/rip.h"
    "/usr/ns-3-dev/src/internet/model/ripng-header.h"
    "/usr/ns-3-dev/src/internet/model/ripng.h"
    "/usr/ns-3-dev/src/internet/model/rtt-estimator.h"
    "/usr/ns-3-dev/src/internet/model/tcp-bbr.h"
    "/usr/ns-3-dev/src/internet/model/tcp-bic.h"
    "/usr/ns-3-dev/src/internet/model/tcp-congestion-ops.h"
    "/usr/ns-3-dev/src/internet/model/tcp-cubic.h"
    "/usr/ns-3-dev/src/internet/model/tcp-dctcp.h"
    "/usr/ns-3-dev/src/internet/model/tcp-header.h"
    "/usr/ns-3-dev/src/internet/model/tcp-highspeed.h"
    "/usr/ns-3-dev/src/internet/model/tcp-htcp.h"
    "/usr/ns-3-dev/src/internet/model/tcp-hybla.h"
    "/usr/ns-3-dev/src/internet/model/tcp-illinois.h"
    "/usr/ns-3-dev/src/internet/model/tcp-l4-protocol.h"
    "/usr/ns-3-dev/src/internet/model/tcp-ledbat.h"
    "/usr/ns-3-dev/src/internet/model/tcp-linux-reno.h"
    "/usr/ns-3-dev/src/internet/model/tcp-lp.h"
    "/usr/ns-3-dev/src/internet/model/tcp-option-rfc793.h"
    "/usr/ns-3-dev/src/internet/model/tcp-option-sack-permitted.h"
    "/usr/ns-3-dev/src/internet/model/tcp-option-sack.h"
    "/usr/ns-3-dev/src/internet/model/tcp-option-ts.h"
    "/usr/ns-3-dev/src/internet/model/tcp-option-winscale.h"
    "/usr/ns-3-dev/src/internet/model/tcp-option.h"
    "/usr/ns-3-dev/src/internet/model/tcp-prr-recovery.h"
    "/usr/ns-3-dev/src/internet/model/tcp-rate-ops.h"
    "/usr/ns-3-dev/src/internet/model/tcp-recovery-ops.h"
    "/usr/ns-3-dev/src/internet/model/tcp-rx-buffer.h"
    "/usr/ns-3-dev/src/internet/model/tcp-scalable.h"
    "/usr/ns-3-dev/src/internet/model/tcp-socket-base.h"
    "/usr/ns-3-dev/src/internet/model/tcp-socket-factory.h"
    "/usr/ns-3-dev/src/internet/model/tcp-socket-state.h"
    "/usr/ns-3-dev/src/internet/model/tcp-socket.h"
    "/usr/ns-3-dev/src/internet/model/tcp-tx-buffer.h"
    "/usr/ns-3-dev/src/internet/model/tcp-tx-item.h"
    "/usr/ns-3-dev/src/internet/model/tcp-vegas.h"
    "/usr/ns-3-dev/src/internet/model/tcp-veno.h"
    "/usr/ns-3-dev/src/internet/model/tcp-westwood-plus.h"
    "/usr/ns-3-dev/src/internet/model/tcp-yeah.h"
    "/usr/ns-3-dev/src/internet/model/udp-header.h"
    "/usr/ns-3-dev/src/internet/model/udp-l4-protocol.h"
    "/usr/ns-3-dev/src/internet/model/udp-socket-factory.h"
    "/usr/ns-3-dev/src/internet/model/udp-socket.h"
    "/usr/ns-3-dev/src/internet/model/windowed-filter.h"
    "/usr/ns-3-dev/build/include/ns3/internet-module.h"
    )
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/usr/ns-3-dev/cmake-cache/src/internet/examples/cmake_install.cmake")

endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/usr/ns-3-dev/cmake-cache/src/internet/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
