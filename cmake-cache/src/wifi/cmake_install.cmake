# Install script for directory: /usr/ns-3-dev/src/wifi

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
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-wifi-optimized.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-wifi-optimized.so")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-wifi-optimized.so"
         RPATH "/usr/local/lib:$ORIGIN/:$ORIGIN/../lib")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/usr/ns-3-dev/build/lib/libns3.39-wifi-optimized.so")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-wifi-optimized.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-wifi-optimized.so")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-wifi-optimized.so"
         OLD_RPATH "/usr/ns-3-dev/build/lib:::::::::::::::"
         NEW_RPATH "/usr/local/lib:$ORIGIN/:$ORIGIN/../lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-wifi-optimized.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/ns3" TYPE FILE FILES
    "/usr/ns-3-dev/src/wifi/helper/athstats-helper.h"
    "/usr/ns-3-dev/src/wifi/helper/spectrum-wifi-helper.h"
    "/usr/ns-3-dev/src/wifi/helper/wifi-helper.h"
    "/usr/ns-3-dev/src/wifi/helper/wifi-mac-helper.h"
    "/usr/ns-3-dev/src/wifi/helper/wifi-radio-energy-model-helper.h"
    "/usr/ns-3-dev/src/wifi/helper/yans-wifi-helper.h"
    "/usr/ns-3-dev/src/wifi/model/adhoc-wifi-mac.h"
    "/usr/ns-3-dev/src/wifi/model/ampdu-subframe-header.h"
    "/usr/ns-3-dev/src/wifi/model/ampdu-tag.h"
    "/usr/ns-3-dev/src/wifi/model/amsdu-subframe-header.h"
    "/usr/ns-3-dev/src/wifi/model/ap-wifi-mac.h"
    "/usr/ns-3-dev/src/wifi/model/block-ack-agreement.h"
    "/usr/ns-3-dev/src/wifi/model/block-ack-manager.h"
    "/usr/ns-3-dev/src/wifi/model/block-ack-type.h"
    "/usr/ns-3-dev/src/wifi/model/block-ack-window.h"
    "/usr/ns-3-dev/src/wifi/model/capability-information.h"
    "/usr/ns-3-dev/src/wifi/model/channel-access-manager.h"
    "/usr/ns-3-dev/src/wifi/model/ctrl-headers.h"
    "/usr/ns-3-dev/src/wifi/model/edca-parameter-set.h"
    "/usr/ns-3-dev/src/wifi/model/eht/default-emlsr-manager.h"
    "/usr/ns-3-dev/src/wifi/model/eht/eht-capabilities.h"
    "/usr/ns-3-dev/src/wifi/model/eht/eht-configuration.h"
    "/usr/ns-3-dev/src/wifi/model/eht/eht-frame-exchange-manager.h"
    "/usr/ns-3-dev/src/wifi/model/eht/eht-operation.h"
    "/usr/ns-3-dev/src/wifi/model/eht/tid-to-link-mapping-element.h"
    "/usr/ns-3-dev/src/wifi/model/eht/eht-phy.h"
    "/usr/ns-3-dev/src/wifi/model/eht/eht-ppdu.h"
    "/usr/ns-3-dev/src/wifi/model/eht/emlsr-manager.h"
    "/usr/ns-3-dev/src/wifi/model/eht/multi-link-element.h"
    "/usr/ns-3-dev/src/wifi/model/error-rate-model.h"
    "/usr/ns-3-dev/src/wifi/model/extended-capabilities.h"
    "/usr/ns-3-dev/src/wifi/model/fcfs-wifi-queue-scheduler.h"
    "/usr/ns-3-dev/src/wifi/model/frame-capture-model.h"
    "/usr/ns-3-dev/src/wifi/model/frame-exchange-manager.h"
    "/usr/ns-3-dev/src/wifi/model/he/constant-obss-pd-algorithm.h"
    "/usr/ns-3-dev/src/wifi/model/he/he-capabilities.h"
    "/usr/ns-3-dev/src/wifi/model/he/he-configuration.h"
    "/usr/ns-3-dev/src/wifi/model/he/he-frame-exchange-manager.h"
    "/usr/ns-3-dev/src/wifi/model/he/he-operation.h"
    "/usr/ns-3-dev/src/wifi/model/he/he-phy.h"
    "/usr/ns-3-dev/src/wifi/model/he/he-ppdu.h"
    "/usr/ns-3-dev/src/wifi/model/he/he-ru.h"
    "/usr/ns-3-dev/src/wifi/model/he/mu-edca-parameter-set.h"
    "/usr/ns-3-dev/src/wifi/model/he/mu-snr-tag.h"
    "/usr/ns-3-dev/src/wifi/model/he/multi-user-scheduler.h"
    "/usr/ns-3-dev/src/wifi/model/he/obss-pd-algorithm.h"
    "/usr/ns-3-dev/src/wifi/model/he/rr-multi-user-scheduler.h"
    "/usr/ns-3-dev/src/wifi/model/ht/ht-capabilities.h"
    "/usr/ns-3-dev/src/wifi/model/ht/ht-configuration.h"
    "/usr/ns-3-dev/src/wifi/model/ht/ht-frame-exchange-manager.h"
    "/usr/ns-3-dev/src/wifi/model/ht/ht-operation.h"
    "/usr/ns-3-dev/src/wifi/model/ht/ht-phy.h"
    "/usr/ns-3-dev/src/wifi/model/ht/ht-ppdu.h"
    "/usr/ns-3-dev/src/wifi/model/interference-helper.h"
    "/usr/ns-3-dev/src/wifi/model/mac-rx-middle.h"
    "/usr/ns-3-dev/src/wifi/model/mac-tx-middle.h"
    "/usr/ns-3-dev/src/wifi/model/mgt-headers.h"
    "/usr/ns-3-dev/src/wifi/model/mpdu-aggregator.h"
    "/usr/ns-3-dev/src/wifi/model/msdu-aggregator.h"
    "/usr/ns-3-dev/src/wifi/model/nist-error-rate-model.h"
    "/usr/ns-3-dev/src/wifi/model/non-ht/dsss-error-rate-model.h"
    "/usr/ns-3-dev/src/wifi/model/non-ht/dsss-parameter-set.h"
    "/usr/ns-3-dev/src/wifi/model/non-ht/dsss-phy.h"
    "/usr/ns-3-dev/src/wifi/model/non-ht/dsss-ppdu.h"
    "/usr/ns-3-dev/src/wifi/model/non-ht/erp-information.h"
    "/usr/ns-3-dev/src/wifi/model/non-ht/erp-ofdm-phy.h"
    "/usr/ns-3-dev/src/wifi/model/non-ht/erp-ofdm-ppdu.h"
    "/usr/ns-3-dev/src/wifi/model/non-ht/ofdm-phy.h"
    "/usr/ns-3-dev/src/wifi/model/non-ht/ofdm-ppdu.h"
    "/usr/ns-3-dev/src/wifi/model/non-inheritance.h"
    "/usr/ns-3-dev/src/wifi/model/originator-block-ack-agreement.h"
    "/usr/ns-3-dev/src/wifi/model/phy-entity.h"
    "/usr/ns-3-dev/src/wifi/model/preamble-detection-model.h"
    "/usr/ns-3-dev/src/wifi/model/qos-frame-exchange-manager.h"
    "/usr/ns-3-dev/src/wifi/model/qos-txop.h"
    "/usr/ns-3-dev/src/wifi/model/qos-utils.h"
    "/usr/ns-3-dev/src/wifi/model/rate-control/aarf-wifi-manager.h"
    "/usr/ns-3-dev/src/wifi/model/rate-control/aarfcd-wifi-manager.h"
    "/usr/ns-3-dev/src/wifi/model/rate-control/amrr-wifi-manager.h"
    "/usr/ns-3-dev/src/wifi/model/rate-control/aparf-wifi-manager.h"
    "/usr/ns-3-dev/src/wifi/model/rate-control/arf-wifi-manager.h"
    "/usr/ns-3-dev/src/wifi/model/rate-control/cara-wifi-manager.h"
    "/usr/ns-3-dev/src/wifi/model/rate-control/constant-rate-wifi-manager.h"
    "/usr/ns-3-dev/src/wifi/model/rate-control/ideal-wifi-manager.h"
    "/usr/ns-3-dev/src/wifi/model/rate-control/minstrel-ht-wifi-manager.h"
    "/usr/ns-3-dev/src/wifi/model/rate-control/minstrel-wifi-manager.h"
    "/usr/ns-3-dev/src/wifi/model/rate-control/onoe-wifi-manager.h"
    "/usr/ns-3-dev/src/wifi/model/rate-control/parf-wifi-manager.h"
    "/usr/ns-3-dev/src/wifi/model/rate-control/rraa-wifi-manager.h"
    "/usr/ns-3-dev/src/wifi/model/rate-control/rrpaa-wifi-manager.h"
    "/usr/ns-3-dev/src/wifi/model/rate-control/thompson-sampling-wifi-manager.h"
    "/usr/ns-3-dev/src/wifi/model/recipient-block-ack-agreement.h"
    "/usr/ns-3-dev/src/wifi/model/reduced-neighbor-report.h"
    "/usr/ns-3-dev/src/wifi/model/reference/error-rate-tables.h"
    "/usr/ns-3-dev/src/wifi/model/simple-frame-capture-model.h"
    "/usr/ns-3-dev/src/wifi/model/snr-tag.h"
    "/usr/ns-3-dev/src/wifi/model/spectrum-wifi-phy.h"
    "/usr/ns-3-dev/src/wifi/model/ssid.h"
    "/usr/ns-3-dev/src/wifi/model/sta-wifi-mac.h"
    "/usr/ns-3-dev/src/wifi/model/status-code.h"
    "/usr/ns-3-dev/src/wifi/model/supported-rates.h"
    "/usr/ns-3-dev/src/wifi/model/table-based-error-rate-model.h"
    "/usr/ns-3-dev/src/wifi/model/threshold-preamble-detection-model.h"
    "/usr/ns-3-dev/src/wifi/model/txop.h"
    "/usr/ns-3-dev/src/wifi/model/vht/vht-capabilities.h"
    "/usr/ns-3-dev/src/wifi/model/vht/vht-configuration.h"
    "/usr/ns-3-dev/src/wifi/model/vht/vht-frame-exchange-manager.h"
    "/usr/ns-3-dev/src/wifi/model/vht/vht-operation.h"
    "/usr/ns-3-dev/src/wifi/model/vht/vht-phy.h"
    "/usr/ns-3-dev/src/wifi/model/vht/vht-ppdu.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-ack-manager.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-acknowledgment.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-assoc-manager.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-bandwidth-filter.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-default-ack-manager.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-default-assoc-manager.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-default-protection-manager.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-information-element.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-mac-header.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-mac-queue-container.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-mac-queue-elem.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-mac-queue-scheduler-impl.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-mac-queue-scheduler.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-mac-queue.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-mac-trailer.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-mac.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-mgt-header.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-mode.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-mpdu-type.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-mpdu.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-net-device.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-phy-band.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-phy-common.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-phy-listener.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-phy-operating-channel.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-phy-state-helper.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-phy-state.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-phy.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-ppdu.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-protection-manager.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-protection.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-psdu.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-radio-energy-model.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-remote-station-info.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-remote-station-manager.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-spectrum-phy-interface.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-spectrum-signal-parameters.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-standards.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-tx-current-model.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-tx-parameters.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-tx-timer.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-tx-vector.h"
    "/usr/ns-3-dev/src/wifi/model/wifi-utils.h"
    "/usr/ns-3-dev/src/wifi/model/yans-error-rate-model.h"
    "/usr/ns-3-dev/src/wifi/model/yans-wifi-channel.h"
    "/usr/ns-3-dev/src/wifi/model/yans-wifi-phy.h"
    "/usr/ns-3-dev/build/include/ns3/wifi-module.h"
    )
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/usr/ns-3-dev/cmake-cache/src/wifi/examples/cmake_install.cmake")

endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/usr/ns-3-dev/cmake-cache/src/wifi/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
