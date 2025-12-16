# Install script for directory: /usr/ns-3-dev/src/lte

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
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-lte-optimized.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-lte-optimized.so")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-lte-optimized.so"
         RPATH "/usr/local/lib:$ORIGIN/:$ORIGIN/../lib")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/usr/ns-3-dev/build/lib/libns3.39-lte-optimized.so")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-lte-optimized.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-lte-optimized.so")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-lte-optimized.so"
         OLD_RPATH "/usr/ns-3-dev/build/lib:::::::::::::::"
         NEW_RPATH "/usr/local/lib:$ORIGIN/:$ORIGIN/../lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-lte-optimized.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/ns3" TYPE FILE FILES
    "/usr/ns-3-dev/src/lte/helper/emu-epc-helper.h"
    "/usr/ns-3-dev/src/lte/helper/cc-helper.h"
    "/usr/ns-3-dev/src/lte/helper/epc-helper.h"
    "/usr/ns-3-dev/src/lte/helper/lte-global-pathloss-database.h"
    "/usr/ns-3-dev/src/lte/helper/lte-helper.h"
    "/usr/ns-3-dev/src/lte/helper/lte-hex-grid-enb-topology-helper.h"
    "/usr/ns-3-dev/src/lte/helper/lte-stats-calculator.h"
    "/usr/ns-3-dev/src/lte/helper/mac-stats-calculator.h"
    "/usr/ns-3-dev/src/lte/helper/no-backhaul-epc-helper.h"
    "/usr/ns-3-dev/src/lte/helper/phy-rx-stats-calculator.h"
    "/usr/ns-3-dev/src/lte/helper/phy-stats-calculator.h"
    "/usr/ns-3-dev/src/lte/helper/phy-tx-stats-calculator.h"
    "/usr/ns-3-dev/src/lte/helper/point-to-point-epc-helper.h"
    "/usr/ns-3-dev/src/lte/helper/radio-bearer-stats-calculator.h"
    "/usr/ns-3-dev/src/lte/helper/radio-bearer-stats-connector.h"
    "/usr/ns-3-dev/src/lte/helper/radio-environment-map-helper.h"
    "/usr/ns-3-dev/src/lte/model/a2-a4-rsrq-handover-algorithm.h"
    "/usr/ns-3-dev/src/lte/model/a3-rsrp-handover-algorithm.h"
    "/usr/ns-3-dev/src/lte/model/component-carrier-enb.h"
    "/usr/ns-3-dev/src/lte/model/component-carrier-ue.h"
    "/usr/ns-3-dev/src/lte/model/component-carrier.h"
    "/usr/ns-3-dev/src/lte/model/cqa-ff-mac-scheduler.h"
    "/usr/ns-3-dev/src/lte/model/epc-enb-application.h"
    "/usr/ns-3-dev/src/lte/model/epc-enb-s1-sap.h"
    "/usr/ns-3-dev/src/lte/model/epc-gtpc-header.h"
    "/usr/ns-3-dev/src/lte/model/epc-gtpu-header.h"
    "/usr/ns-3-dev/src/lte/model/epc-mme-application.h"
    "/usr/ns-3-dev/src/lte/model/epc-pgw-application.h"
    "/usr/ns-3-dev/src/lte/model/epc-s11-sap.h"
    "/usr/ns-3-dev/src/lte/model/epc-s1ap-sap.h"
    "/usr/ns-3-dev/src/lte/model/epc-sgw-application.h"
    "/usr/ns-3-dev/src/lte/model/epc-tft-classifier.h"
    "/usr/ns-3-dev/src/lte/model/epc-tft.h"
    "/usr/ns-3-dev/src/lte/model/epc-ue-nas.h"
    "/usr/ns-3-dev/src/lte/model/epc-x2-header.h"
    "/usr/ns-3-dev/src/lte/model/epc-x2-sap.h"
    "/usr/ns-3-dev/src/lte/model/epc-x2.h"
    "/usr/ns-3-dev/src/lte/model/eps-bearer-tag.h"
    "/usr/ns-3-dev/src/lte/model/eps-bearer.h"
    "/usr/ns-3-dev/src/lte/model/fdbet-ff-mac-scheduler.h"
    "/usr/ns-3-dev/src/lte/model/fdmt-ff-mac-scheduler.h"
    "/usr/ns-3-dev/src/lte/model/fdtbfq-ff-mac-scheduler.h"
    "/usr/ns-3-dev/src/lte/model/ff-mac-common.h"
    "/usr/ns-3-dev/src/lte/model/ff-mac-csched-sap.h"
    "/usr/ns-3-dev/src/lte/model/ff-mac-sched-sap.h"
    "/usr/ns-3-dev/src/lte/model/ff-mac-scheduler.h"
    "/usr/ns-3-dev/src/lte/model/lte-amc.h"
    "/usr/ns-3-dev/src/lte/model/lte-anr-sap.h"
    "/usr/ns-3-dev/src/lte/model/lte-anr.h"
    "/usr/ns-3-dev/src/lte/model/lte-as-sap.h"
    "/usr/ns-3-dev/src/lte/model/lte-asn1-header.h"
    "/usr/ns-3-dev/src/lte/model/lte-ccm-mac-sap.h"
    "/usr/ns-3-dev/src/lte/model/lte-ccm-rrc-sap.h"
    "/usr/ns-3-dev/src/lte/model/lte-chunk-processor.h"
    "/usr/ns-3-dev/src/lte/model/lte-common.h"
    "/usr/ns-3-dev/src/lte/model/lte-control-messages.h"
    "/usr/ns-3-dev/src/lte/model/lte-enb-cmac-sap.h"
    "/usr/ns-3-dev/src/lte/model/lte-enb-component-carrier-manager.h"
    "/usr/ns-3-dev/src/lte/model/lte-enb-cphy-sap.h"
    "/usr/ns-3-dev/src/lte/model/lte-enb-mac.h"
    "/usr/ns-3-dev/src/lte/model/lte-enb-net-device.h"
    "/usr/ns-3-dev/src/lte/model/lte-enb-phy-sap.h"
    "/usr/ns-3-dev/src/lte/model/lte-enb-phy.h"
    "/usr/ns-3-dev/src/lte/model/lte-enb-rrc.h"
    "/usr/ns-3-dev/src/lte/model/lte-ffr-algorithm.h"
    "/usr/ns-3-dev/src/lte/model/lte-ffr-distributed-algorithm.h"
    "/usr/ns-3-dev/src/lte/model/lte-ffr-enhanced-algorithm.h"
    "/usr/ns-3-dev/src/lte/model/lte-ffr-rrc-sap.h"
    "/usr/ns-3-dev/src/lte/model/lte-ffr-sap.h"
    "/usr/ns-3-dev/src/lte/model/lte-ffr-soft-algorithm.h"
    "/usr/ns-3-dev/src/lte/model/lte-fr-hard-algorithm.h"
    "/usr/ns-3-dev/src/lte/model/lte-fr-no-op-algorithm.h"
    "/usr/ns-3-dev/src/lte/model/lte-fr-soft-algorithm.h"
    "/usr/ns-3-dev/src/lte/model/lte-fr-strict-algorithm.h"
    "/usr/ns-3-dev/src/lte/model/lte-handover-algorithm.h"
    "/usr/ns-3-dev/src/lte/model/lte-handover-management-sap.h"
    "/usr/ns-3-dev/src/lte/model/lte-harq-phy.h"
    "/usr/ns-3-dev/src/lte/model/lte-interference.h"
    "/usr/ns-3-dev/src/lte/model/lte-mac-sap.h"
    "/usr/ns-3-dev/src/lte/model/lte-mi-error-model.h"
    "/usr/ns-3-dev/src/lte/model/lte-net-device.h"
    "/usr/ns-3-dev/src/lte/model/lte-pdcp-header.h"
    "/usr/ns-3-dev/src/lte/model/lte-pdcp-sap.h"
    "/usr/ns-3-dev/src/lte/model/lte-pdcp-tag.h"
    "/usr/ns-3-dev/src/lte/model/lte-pdcp.h"
    "/usr/ns-3-dev/src/lte/model/lte-phy-tag.h"
    "/usr/ns-3-dev/src/lte/model/lte-phy.h"
    "/usr/ns-3-dev/src/lte/model/lte-radio-bearer-info.h"
    "/usr/ns-3-dev/src/lte/model/lte-radio-bearer-tag.h"
    "/usr/ns-3-dev/src/lte/model/lte-rlc-am-header.h"
    "/usr/ns-3-dev/src/lte/model/lte-rlc-am.h"
    "/usr/ns-3-dev/src/lte/model/lte-rlc-header.h"
    "/usr/ns-3-dev/src/lte/model/lte-rlc-sap.h"
    "/usr/ns-3-dev/src/lte/model/lte-rlc-sdu-status-tag.h"
    "/usr/ns-3-dev/src/lte/model/lte-rlc-sequence-number.h"
    "/usr/ns-3-dev/src/lte/model/lte-rlc-tag.h"
    "/usr/ns-3-dev/src/lte/model/lte-rlc-tm.h"
    "/usr/ns-3-dev/src/lte/model/lte-rlc-um.h"
    "/usr/ns-3-dev/src/lte/model/lte-rlc.h"
    "/usr/ns-3-dev/src/lte/model/lte-rrc-header.h"
    "/usr/ns-3-dev/src/lte/model/lte-rrc-protocol-ideal.h"
    "/usr/ns-3-dev/src/lte/model/lte-rrc-protocol-real.h"
    "/usr/ns-3-dev/src/lte/model/lte-rrc-sap.h"
    "/usr/ns-3-dev/src/lte/model/lte-spectrum-phy.h"
    "/usr/ns-3-dev/src/lte/model/lte-spectrum-signal-parameters.h"
    "/usr/ns-3-dev/src/lte/model/lte-spectrum-value-helper.h"
    "/usr/ns-3-dev/src/lte/model/lte-ue-ccm-rrc-sap.h"
    "/usr/ns-3-dev/src/lte/model/lte-ue-cmac-sap.h"
    "/usr/ns-3-dev/src/lte/model/lte-ue-component-carrier-manager.h"
    "/usr/ns-3-dev/src/lte/model/lte-ue-cphy-sap.h"
    "/usr/ns-3-dev/src/lte/model/lte-ue-mac.h"
    "/usr/ns-3-dev/src/lte/model/lte-ue-net-device.h"
    "/usr/ns-3-dev/src/lte/model/lte-ue-phy-sap.h"
    "/usr/ns-3-dev/src/lte/model/lte-ue-phy.h"
    "/usr/ns-3-dev/src/lte/model/lte-ue-power-control.h"
    "/usr/ns-3-dev/src/lte/model/lte-ue-rrc.h"
    "/usr/ns-3-dev/src/lte/model/lte-vendor-specific-parameters.h"
    "/usr/ns-3-dev/src/lte/model/no-op-component-carrier-manager.h"
    "/usr/ns-3-dev/src/lte/model/no-op-handover-algorithm.h"
    "/usr/ns-3-dev/src/lte/model/pf-ff-mac-scheduler.h"
    "/usr/ns-3-dev/src/lte/model/pss-ff-mac-scheduler.h"
    "/usr/ns-3-dev/src/lte/model/rem-spectrum-phy.h"
    "/usr/ns-3-dev/src/lte/model/rr-ff-mac-scheduler.h"
    "/usr/ns-3-dev/src/lte/model/simple-ue-component-carrier-manager.h"
    "/usr/ns-3-dev/src/lte/model/tdbet-ff-mac-scheduler.h"
    "/usr/ns-3-dev/src/lte/model/tdmt-ff-mac-scheduler.h"
    "/usr/ns-3-dev/src/lte/model/tdtbfq-ff-mac-scheduler.h"
    "/usr/ns-3-dev/src/lte/model/tta-ff-mac-scheduler.h"
    "/usr/ns-3-dev/build/include/ns3/lte-module.h"
    )
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/usr/ns-3-dev/cmake-cache/src/lte/examples/cmake_install.cmake")

endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/usr/ns-3-dev/cmake-cache/src/lte/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
