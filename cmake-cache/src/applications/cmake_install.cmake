# Install script for directory: /usr/ns-3-dev/src/applications

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
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-applications-optimized.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-applications-optimized.so")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-applications-optimized.so"
         RPATH "/usr/local/lib:$ORIGIN/:$ORIGIN/../lib")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/usr/ns-3-dev/build/lib/libns3.39-applications-optimized.so")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-applications-optimized.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-applications-optimized.so")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-applications-optimized.so"
         OLD_RPATH "/usr/ns-3-dev/build/lib:::::::::::::::"
         NEW_RPATH "/usr/local/lib:$ORIGIN/:$ORIGIN/../lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-applications-optimized.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/ns3" TYPE FILE FILES
    "/usr/ns-3-dev/src/applications/helper/bulk-send-helper.h"
    "/usr/ns-3-dev/src/applications/helper/on-off-helper.h"
    "/usr/ns-3-dev/src/applications/helper/packet-sink-helper.h"
    "/usr/ns-3-dev/src/applications/helper/three-gpp-http-helper.h"
    "/usr/ns-3-dev/src/applications/helper/udp-client-server-helper.h"
    "/usr/ns-3-dev/src/applications/helper/udp-echo-helper.h"
    "/usr/ns-3-dev/src/applications/model/application-packet-probe.h"
    "/usr/ns-3-dev/src/applications/model/bulk-send-application.h"
    "/usr/ns-3-dev/src/applications/model/onoff-application.h"
    "/usr/ns-3-dev/src/applications/model/packet-loss-counter.h"
    "/usr/ns-3-dev/src/applications/model/packet-sink.h"
    "/usr/ns-3-dev/src/applications/model/seq-ts-echo-header.h"
    "/usr/ns-3-dev/src/applications/model/seq-ts-header.h"
    "/usr/ns-3-dev/src/applications/model/seq-ts-size-header.h"
    "/usr/ns-3-dev/src/applications/model/three-gpp-http-client.h"
    "/usr/ns-3-dev/src/applications/model/three-gpp-http-header.h"
    "/usr/ns-3-dev/src/applications/model/three-gpp-http-server.h"
    "/usr/ns-3-dev/src/applications/model/three-gpp-http-variables.h"
    "/usr/ns-3-dev/src/applications/model/udp-client.h"
    "/usr/ns-3-dev/src/applications/model/udp-echo-client.h"
    "/usr/ns-3-dev/src/applications/model/udp-echo-server.h"
    "/usr/ns-3-dev/src/applications/model/udp-server.h"
    "/usr/ns-3-dev/src/applications/model/udp-trace-client.h"
    "/usr/ns-3-dev/build/include/ns3/applications-module.h"
    )
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/usr/ns-3-dev/cmake-cache/src/applications/examples/cmake_install.cmake")

endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/usr/ns-3-dev/cmake-cache/src/applications/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
