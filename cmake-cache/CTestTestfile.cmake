# CMake generated Testfile for 
# Source directory: /usr/ns-3-dev
# Build directory: /usr/ns-3-dev/cmake-cache
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(ctest-stdlib_pch_exec "ns3.39-stdlib_pch_exec-optimized")
set_tests_properties(ctest-stdlib_pch_exec PROPERTIES  WORKING_DIRECTORY "/usr/ns-3-dev/cmake-cache/" _BACKTRACE_TRIPLES "/usr/ns-3-dev/build-support/macros-and-definitions.cmake;1584;add_test;/usr/ns-3-dev/build-support/macros-and-definitions.cmake;1501;set_runtime_outputdirectory;/usr/ns-3-dev/CMakeLists.txt;147;process_options;/usr/ns-3-dev/CMakeLists.txt;0;")
subdirs("contrib/evalvid")
subdirs("contrib/ofswitch13")
subdirs("src")
subdirs("examples")
subdirs("scratch")
subdirs("utils")
