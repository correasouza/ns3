# Install script for directory: /usr/ns-3-dev/src/core

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
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-core-optimized.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-core-optimized.so")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-core-optimized.so"
         RPATH "/usr/local/lib:$ORIGIN/:$ORIGIN/../lib")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/usr/ns-3-dev/build/lib/libns3.39-core-optimized.so")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-core-optimized.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-core-optimized.so")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-core-optimized.so"
         OLD_RPATH "/usr/ns-3-dev/build/lib:::::::::::::::"
         NEW_RPATH "/usr/local/lib:$ORIGIN/:$ORIGIN/../lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.39-core-optimized.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/ns3" TYPE FILE FILES
    "/usr/ns-3-dev/src/core/model/int64x64-128.h"
    "/usr/ns-3-dev/src/core/model/example-as-test.h"
    "/usr/ns-3-dev/src/core/helper/csv-reader.h"
    "/usr/ns-3-dev/src/core/helper/event-garbage-collector.h"
    "/usr/ns-3-dev/src/core/helper/random-variable-stream-helper.h"
    "/usr/ns-3-dev/src/core/model/abort.h"
    "/usr/ns-3-dev/src/core/model/ascii-file.h"
    "/usr/ns-3-dev/src/core/model/ascii-test.h"
    "/usr/ns-3-dev/src/core/model/assert.h"
    "/usr/ns-3-dev/src/core/model/attribute-accessor-helper.h"
    "/usr/ns-3-dev/src/core/model/attribute-construction-list.h"
    "/usr/ns-3-dev/src/core/model/attribute-container.h"
    "/usr/ns-3-dev/src/core/model/attribute-helper.h"
    "/usr/ns-3-dev/src/core/model/attribute.h"
    "/usr/ns-3-dev/src/core/model/boolean.h"
    "/usr/ns-3-dev/src/core/model/breakpoint.h"
    "/usr/ns-3-dev/src/core/model/build-profile.h"
    "/usr/ns-3-dev/src/core/model/calendar-scheduler.h"
    "/usr/ns-3-dev/src/core/model/callback.h"
    "/usr/ns-3-dev/src/core/model/command-line.h"
    "/usr/ns-3-dev/src/core/model/config.h"
    "/usr/ns-3-dev/src/core/model/default-deleter.h"
    "/usr/ns-3-dev/src/core/model/default-simulator-impl.h"
    "/usr/ns-3-dev/src/core/model/deprecated.h"
    "/usr/ns-3-dev/src/core/model/des-metrics.h"
    "/usr/ns-3-dev/src/core/model/double.h"
    "/usr/ns-3-dev/src/core/model/enum.h"
    "/usr/ns-3-dev/src/core/model/event-id.h"
    "/usr/ns-3-dev/src/core/model/event-impl.h"
    "/usr/ns-3-dev/src/core/model/fatal-error.h"
    "/usr/ns-3-dev/src/core/model/fatal-impl.h"
    "/usr/ns-3-dev/src/core/model/fd-reader.h"
    "/usr/ns-3-dev/src/core/model/environment-variable.h"
    "/usr/ns-3-dev/src/core/model/global-value.h"
    "/usr/ns-3-dev/src/core/model/hash-fnv.h"
    "/usr/ns-3-dev/src/core/model/hash-function.h"
    "/usr/ns-3-dev/src/core/model/hash-murmur3.h"
    "/usr/ns-3-dev/src/core/model/hash.h"
    "/usr/ns-3-dev/src/core/model/heap-scheduler.h"
    "/usr/ns-3-dev/src/core/model/int-to-type.h"
    "/usr/ns-3-dev/src/core/model/int64x64-double.h"
    "/usr/ns-3-dev/src/core/model/int64x64.h"
    "/usr/ns-3-dev/src/core/model/integer.h"
    "/usr/ns-3-dev/src/core/model/length.h"
    "/usr/ns-3-dev/src/core/model/list-scheduler.h"
    "/usr/ns-3-dev/src/core/model/log-macros-disabled.h"
    "/usr/ns-3-dev/src/core/model/log-macros-enabled.h"
    "/usr/ns-3-dev/src/core/model/log.h"
    "/usr/ns-3-dev/src/core/model/make-event.h"
    "/usr/ns-3-dev/src/core/model/map-scheduler.h"
    "/usr/ns-3-dev/src/core/model/math.h"
    "/usr/ns-3-dev/src/core/model/names.h"
    "/usr/ns-3-dev/src/core/model/node-printer.h"
    "/usr/ns-3-dev/src/core/model/nstime.h"
    "/usr/ns-3-dev/src/core/model/object-base.h"
    "/usr/ns-3-dev/src/core/model/object-factory.h"
    "/usr/ns-3-dev/src/core/model/object-map.h"
    "/usr/ns-3-dev/src/core/model/object-ptr-container.h"
    "/usr/ns-3-dev/src/core/model/object-vector.h"
    "/usr/ns-3-dev/src/core/model/object.h"
    "/usr/ns-3-dev/src/core/model/pair.h"
    "/usr/ns-3-dev/src/core/model/pointer.h"
    "/usr/ns-3-dev/src/core/model/priority-queue-scheduler.h"
    "/usr/ns-3-dev/src/core/model/ptr.h"
    "/usr/ns-3-dev/src/core/model/random-variable-stream.h"
    "/usr/ns-3-dev/src/core/model/rng-seed-manager.h"
    "/usr/ns-3-dev/src/core/model/rng-stream.h"
    "/usr/ns-3-dev/src/core/model/scheduler.h"
    "/usr/ns-3-dev/src/core/model/show-progress.h"
    "/usr/ns-3-dev/src/core/model/simple-ref-count.h"
    "/usr/ns-3-dev/src/core/model/simulation-singleton.h"
    "/usr/ns-3-dev/src/core/model/simulator-impl.h"
    "/usr/ns-3-dev/src/core/model/simulator.h"
    "/usr/ns-3-dev/src/core/model/singleton.h"
    "/usr/ns-3-dev/src/core/model/string.h"
    "/usr/ns-3-dev/src/core/model/synchronizer.h"
    "/usr/ns-3-dev/src/core/model/system-path.h"
    "/usr/ns-3-dev/src/core/model/system-wall-clock-ms.h"
    "/usr/ns-3-dev/src/core/model/system-wall-clock-timestamp.h"
    "/usr/ns-3-dev/src/core/model/test.h"
    "/usr/ns-3-dev/src/core/model/time-printer.h"
    "/usr/ns-3-dev/src/core/model/timer-impl.h"
    "/usr/ns-3-dev/src/core/model/timer.h"
    "/usr/ns-3-dev/src/core/model/trace-source-accessor.h"
    "/usr/ns-3-dev/src/core/model/traced-callback.h"
    "/usr/ns-3-dev/src/core/model/traced-value.h"
    "/usr/ns-3-dev/src/core/model/trickle-timer.h"
    "/usr/ns-3-dev/src/core/model/tuple.h"
    "/usr/ns-3-dev/src/core/model/type-id.h"
    "/usr/ns-3-dev/src/core/model/type-name.h"
    "/usr/ns-3-dev/src/core/model/type-traits.h"
    "/usr/ns-3-dev/src/core/model/uinteger.h"
    "/usr/ns-3-dev/src/core/model/unused.h"
    "/usr/ns-3-dev/src/core/model/valgrind.h"
    "/usr/ns-3-dev/src/core/model/vector.h"
    "/usr/ns-3-dev/src/core/model/warnings.h"
    "/usr/ns-3-dev/src/core/model/watchdog.h"
    "/usr/ns-3-dev/src/core/model/realtime-simulator-impl.h"
    "/usr/ns-3-dev/src/core/model/wall-clock-synchronizer.h"
    "/usr/ns-3-dev/src/core/model/val-array.h"
    "/usr/ns-3-dev/src/core/model/matrix-array.h"
    "/usr/ns-3-dev/build/include/ns3/config-store-config.h"
    "/usr/ns-3-dev/build/include/ns3/core-config.h"
    "/usr/ns-3-dev/build/include/ns3/core-module.h"
    )
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/usr/ns-3-dev/cmake-cache/src/core/examples/cmake_install.cmake")

endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/usr/ns-3-dev/cmake-cache/src/core/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
