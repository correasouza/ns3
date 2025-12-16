# Install script for directory: /usr/ns-3-dev/src/mesh

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
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-mesh-optimized.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-mesh-optimized.so")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-mesh-optimized.so"
         RPATH "/usr/local/lib:$ORIGIN/:$ORIGIN/../lib")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/usr/ns-3-dev/build/lib/libns3.39-mesh-optimized.so")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-mesh-optimized.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-mesh-optimized.so")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-mesh-optimized.so"
         OLD_RPATH "/usr/ns-3-dev/build/lib:::::::::::::::"
         NEW_RPATH "/usr/local/lib:$ORIGIN/:$ORIGIN/../lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-mesh-optimized.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/ns3" TYPE FILE FILES
    "/usr/ns-3-dev/src/mesh/helper/dot11s/dot11s-installer.h"
    "/usr/ns-3-dev/src/mesh/helper/flame/flame-installer.h"
    "/usr/ns-3-dev/src/mesh/helper/mesh-helper.h"
    "/usr/ns-3-dev/src/mesh/helper/mesh-stack-installer.h"
    "/usr/ns-3-dev/src/mesh/model/dot11s/dot11s-mac-header.h"
    "/usr/ns-3-dev/src/mesh/model/dot11s/hwmp-protocol.h"
    "/usr/ns-3-dev/src/mesh/model/dot11s/hwmp-rtable.h"
    "/usr/ns-3-dev/src/mesh/model/dot11s/ie-dot11s-beacon-timing.h"
    "/usr/ns-3-dev/src/mesh/model/dot11s/ie-dot11s-configuration.h"
    "/usr/ns-3-dev/src/mesh/model/dot11s/ie-dot11s-id.h"
    "/usr/ns-3-dev/src/mesh/model/dot11s/ie-dot11s-metric-report.h"
    "/usr/ns-3-dev/src/mesh/model/dot11s/ie-dot11s-peer-management.h"
    "/usr/ns-3-dev/src/mesh/model/dot11s/ie-dot11s-peering-protocol.h"
    "/usr/ns-3-dev/src/mesh/model/dot11s/ie-dot11s-perr.h"
    "/usr/ns-3-dev/src/mesh/model/dot11s/ie-dot11s-prep.h"
    "/usr/ns-3-dev/src/mesh/model/dot11s/ie-dot11s-preq.h"
    "/usr/ns-3-dev/src/mesh/model/dot11s/ie-dot11s-rann.h"
    "/usr/ns-3-dev/src/mesh/model/dot11s/peer-link-frame.h"
    "/usr/ns-3-dev/src/mesh/model/dot11s/peer-link.h"
    "/usr/ns-3-dev/src/mesh/model/dot11s/peer-management-protocol.h"
    "/usr/ns-3-dev/src/mesh/model/flame/flame-header.h"
    "/usr/ns-3-dev/src/mesh/model/flame/flame-protocol-mac.h"
    "/usr/ns-3-dev/src/mesh/model/flame/flame-protocol.h"
    "/usr/ns-3-dev/src/mesh/model/flame/flame-rtable.h"
    "/usr/ns-3-dev/src/mesh/model/mesh-information-element-vector.h"
    "/usr/ns-3-dev/src/mesh/model/mesh-l2-routing-protocol.h"
    "/usr/ns-3-dev/src/mesh/model/mesh-point-device.h"
    "/usr/ns-3-dev/src/mesh/model/mesh-wifi-beacon.h"
    "/usr/ns-3-dev/src/mesh/model/mesh-wifi-interface-mac-plugin.h"
    "/usr/ns-3-dev/src/mesh/model/mesh-wifi-interface-mac.h"
    "/usr/ns-3-dev/build/include/ns3/mesh-module.h"
    )
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/usr/ns-3-dev/cmake-cache/src/mesh/examples/cmake_install.cmake")

endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/usr/ns-3-dev/cmake-cache/src/mesh/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
