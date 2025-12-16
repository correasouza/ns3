# CMake generated Testfile for 
# Source directory: /usr/ns-3-dev/src/tap-bridge
# Build directory: /usr/ns-3-dev/cmake-cache/src/tap-bridge
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(ctest-tap-creator "ns3.39-tap-creator-optimized")
set_tests_properties(ctest-tap-creator PROPERTIES  WORKING_DIRECTORY "/usr/ns-3-dev/build/src/tap-bridge/" _BACKTRACE_TRIPLES "/usr/ns-3-dev/build-support/macros-and-definitions.cmake;1584;add_test;/usr/ns-3-dev/build-support/macros-and-definitions.cmake;1659;set_runtime_outputdirectory;/usr/ns-3-dev/src/tap-bridge/CMakeLists.txt;40;build_exec;/usr/ns-3-dev/src/tap-bridge/CMakeLists.txt;0;")
subdirs("examples")
