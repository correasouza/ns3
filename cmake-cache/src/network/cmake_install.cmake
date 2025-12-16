# Install script for directory: /usr/ns-3-dev/src/network

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
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-network-optimized.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-network-optimized.so")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-network-optimized.so"
         RPATH "/usr/local/lib:$ORIGIN/:$ORIGIN/../lib")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/usr/ns-3-dev/build/lib/libns3.39-network-optimized.so")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-network-optimized.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-network-optimized.so")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-network-optimized.so"
         OLD_RPATH "/usr/ns-3-dev/build/lib:::::::::::::::"
         NEW_RPATH "/usr/local/lib:$ORIGIN/:$ORIGIN/../lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-network-optimized.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/ns3" TYPE FILE FILES
    "/usr/ns-3-dev/src/network/helper/application-container.h"
    "/usr/ns-3-dev/src/network/helper/delay-jitter-estimation.h"
    "/usr/ns-3-dev/src/network/helper/net-device-container.h"
    "/usr/ns-3-dev/src/network/helper/node-container.h"
    "/usr/ns-3-dev/src/network/helper/packet-socket-helper.h"
    "/usr/ns-3-dev/src/network/helper/simple-net-device-helper.h"
    "/usr/ns-3-dev/src/network/helper/trace-helper.h"
    "/usr/ns-3-dev/src/network/model/address.h"
    "/usr/ns-3-dev/src/network/model/application.h"
    "/usr/ns-3-dev/src/network/model/buffer.h"
    "/usr/ns-3-dev/src/network/model/byte-tag-list.h"
    "/usr/ns-3-dev/src/network/model/channel-list.h"
    "/usr/ns-3-dev/src/network/model/channel.h"
    "/usr/ns-3-dev/src/network/model/chunk.h"
    "/usr/ns-3-dev/src/network/model/header.h"
    "/usr/ns-3-dev/src/network/model/net-device.h"
    "/usr/ns-3-dev/src/network/model/nix-vector.h"
    "/usr/ns-3-dev/src/network/model/node-list.h"
    "/usr/ns-3-dev/src/network/model/node.h"
    "/usr/ns-3-dev/src/network/model/packet-metadata.h"
    "/usr/ns-3-dev/src/network/model/packet-tag-list.h"
    "/usr/ns-3-dev/src/network/model/packet.h"
    "/usr/ns-3-dev/src/network/model/socket-factory.h"
    "/usr/ns-3-dev/src/network/model/socket.h"
    "/usr/ns-3-dev/src/network/model/tag-buffer.h"
    "/usr/ns-3-dev/src/network/model/tag.h"
    "/usr/ns-3-dev/src/network/model/trailer.h"
    "/usr/ns-3-dev/src/network/test/header-serialization-test.h"
    "/usr/ns-3-dev/src/network/utils/address-utils.h"
    "/usr/ns-3-dev/src/network/utils/bit-deserializer.h"
    "/usr/ns-3-dev/src/network/utils/bit-serializer.h"
    "/usr/ns-3-dev/src/network/utils/crc32.h"
    "/usr/ns-3-dev/src/network/utils/data-rate.h"
    "/usr/ns-3-dev/src/network/utils/drop-tail-queue.h"
    "/usr/ns-3-dev/src/network/utils/dynamic-queue-limits.h"
    "/usr/ns-3-dev/src/network/utils/error-channel.h"
    "/usr/ns-3-dev/src/network/utils/error-model.h"
    "/usr/ns-3-dev/src/network/utils/ethernet-header.h"
    "/usr/ns-3-dev/src/network/utils/ethernet-trailer.h"
    "/usr/ns-3-dev/src/network/utils/flow-id-tag.h"
    "/usr/ns-3-dev/src/network/utils/generic-phy.h"
    "/usr/ns-3-dev/src/network/utils/inet-socket-address.h"
    "/usr/ns-3-dev/src/network/utils/inet6-socket-address.h"
    "/usr/ns-3-dev/src/network/utils/ipv4-address.h"
    "/usr/ns-3-dev/src/network/utils/ipv6-address.h"
    "/usr/ns-3-dev/src/network/utils/llc-snap-header.h"
    "/usr/ns-3-dev/src/network/utils/lollipop-counter.h"
    "/usr/ns-3-dev/src/network/utils/mac16-address.h"
    "/usr/ns-3-dev/src/network/utils/mac48-address.h"
    "/usr/ns-3-dev/src/network/utils/mac64-address.h"
    "/usr/ns-3-dev/src/network/utils/mac8-address.h"
    "/usr/ns-3-dev/src/network/utils/net-device-queue-interface.h"
    "/usr/ns-3-dev/src/network/utils/output-stream-wrapper.h"
    "/usr/ns-3-dev/src/network/utils/packet-burst.h"
    "/usr/ns-3-dev/src/network/utils/packet-data-calculators.h"
    "/usr/ns-3-dev/src/network/utils/packet-probe.h"
    "/usr/ns-3-dev/src/network/utils/packet-socket-address.h"
    "/usr/ns-3-dev/src/network/utils/packet-socket-client.h"
    "/usr/ns-3-dev/src/network/utils/packet-socket-factory.h"
    "/usr/ns-3-dev/src/network/utils/packet-socket-server.h"
    "/usr/ns-3-dev/src/network/utils/packet-socket.h"
    "/usr/ns-3-dev/src/network/utils/packetbb.h"
    "/usr/ns-3-dev/src/network/utils/pcap-file-wrapper.h"
    "/usr/ns-3-dev/src/network/utils/pcap-file.h"
    "/usr/ns-3-dev/src/network/utils/pcap-test.h"
    "/usr/ns-3-dev/src/network/utils/queue-fwd.h"
    "/usr/ns-3-dev/src/network/utils/queue-item.h"
    "/usr/ns-3-dev/src/network/utils/queue-limits.h"
    "/usr/ns-3-dev/src/network/utils/queue-size.h"
    "/usr/ns-3-dev/src/network/utils/queue.h"
    "/usr/ns-3-dev/src/network/utils/radiotap-header.h"
    "/usr/ns-3-dev/src/network/utils/sequence-number.h"
    "/usr/ns-3-dev/src/network/utils/simple-channel.h"
    "/usr/ns-3-dev/src/network/utils/simple-net-device.h"
    "/usr/ns-3-dev/src/network/utils/sll-header.h"
    "/usr/ns-3-dev/src/network/utils/timestamp-tag.h"
    "/usr/ns-3-dev/build/include/ns3/network-module.h"
    )
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/usr/ns-3-dev/cmake-cache/src/network/examples/cmake_install.cmake")

endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/usr/ns-3-dev/cmake-cache/src/network/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
