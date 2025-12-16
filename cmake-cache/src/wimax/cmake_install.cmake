# Install script for directory: /usr/ns-3-dev/src/wimax

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
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-wimax-optimized.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-wimax-optimized.so")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-wimax-optimized.so"
         RPATH "/usr/local/lib:$ORIGIN/:$ORIGIN/../lib")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/usr/ns-3-dev/build/lib/libns3.39-wimax-optimized.so")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-wimax-optimized.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-wimax-optimized.so")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-wimax-optimized.so"
         OLD_RPATH "/usr/ns-3-dev/build/lib:::::::::::::::"
         NEW_RPATH "/usr/local/lib:$ORIGIN/:$ORIGIN/../lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-wimax-optimized.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/ns3" TYPE FILE FILES
    "/usr/ns-3-dev/src/wimax/helper/wimax-helper.h"
    "/usr/ns-3-dev/src/wimax/model/wimax-channel.h"
    "/usr/ns-3-dev/src/wimax/model/wimax-net-device.h"
    "/usr/ns-3-dev/src/wimax/model/bs-net-device.h"
    "/usr/ns-3-dev/src/wimax/model/ss-net-device.h"
    "/usr/ns-3-dev/src/wimax/model/cid.h"
    "/usr/ns-3-dev/src/wimax/model/cid-factory.h"
    "/usr/ns-3-dev/src/wimax/model/ofdm-downlink-frame-prefix.h"
    "/usr/ns-3-dev/src/wimax/model/wimax-connection.h"
    "/usr/ns-3-dev/src/wimax/model/ss-record.h"
    "/usr/ns-3-dev/src/wimax/model/mac-messages.h"
    "/usr/ns-3-dev/src/wimax/model/dl-mac-messages.h"
    "/usr/ns-3-dev/src/wimax/model/ul-mac-messages.h"
    "/usr/ns-3-dev/src/wimax/model/wimax-phy.h"
    "/usr/ns-3-dev/src/wimax/model/simple-ofdm-wimax-phy.h"
    "/usr/ns-3-dev/src/wimax/model/simple-ofdm-wimax-channel.h"
    "/usr/ns-3-dev/src/wimax/model/send-params.h"
    "/usr/ns-3-dev/src/wimax/model/service-flow.h"
    "/usr/ns-3-dev/src/wimax/model/ss-manager.h"
    "/usr/ns-3-dev/src/wimax/model/connection-manager.h"
    "/usr/ns-3-dev/src/wimax/model/wimax-mac-header.h"
    "/usr/ns-3-dev/src/wimax/model/wimax-mac-queue.h"
    "/usr/ns-3-dev/src/wimax/model/crc8.h"
    "/usr/ns-3-dev/src/wimax/model/service-flow-manager.h"
    "/usr/ns-3-dev/src/wimax/model/bs-uplink-scheduler.h"
    "/usr/ns-3-dev/src/wimax/model/bs-uplink-scheduler-simple.h"
    "/usr/ns-3-dev/src/wimax/model/bs-uplink-scheduler-mbqos.h"
    "/usr/ns-3-dev/src/wimax/model/bs-uplink-scheduler-rtps.h"
    "/usr/ns-3-dev/src/wimax/model/ul-job.h"
    "/usr/ns-3-dev/src/wimax/model/bs-scheduler.h"
    "/usr/ns-3-dev/src/wimax/model/bs-scheduler-simple.h"
    "/usr/ns-3-dev/src/wimax/model/bs-scheduler-rtps.h"
    "/usr/ns-3-dev/src/wimax/model/service-flow-record.h"
    "/usr/ns-3-dev/src/wimax/model/snr-to-block-error-rate-record.h"
    "/usr/ns-3-dev/src/wimax/model/snr-to-block-error-rate-manager.h"
    "/usr/ns-3-dev/src/wimax/model/simple-ofdm-send-param.h"
    "/usr/ns-3-dev/src/wimax/model/ss-service-flow-manager.h"
    "/usr/ns-3-dev/src/wimax/model/bs-service-flow-manager.h"
    "/usr/ns-3-dev/src/wimax/model/cs-parameters.h"
    "/usr/ns-3-dev/src/wimax/model/ipcs-classifier-record.h"
    "/usr/ns-3-dev/src/wimax/model/wimax-tlv.h"
    "/usr/ns-3-dev/src/wimax/model/ipcs-classifier.h"
    "/usr/ns-3-dev/src/wimax/model/bvec.h"
    "/usr/ns-3-dev/src/wimax/model/wimax-mac-to-mac-header.h"
    "/usr/ns-3-dev/build/include/ns3/wimax-module.h"
    )
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/usr/ns-3-dev/cmake-cache/src/wimax/examples/cmake_install.cmake")

endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/usr/ns-3-dev/cmake-cache/src/wimax/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
