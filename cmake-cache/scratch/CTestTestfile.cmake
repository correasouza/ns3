# CMake generated Testfile for 
# Source directory: /usr/ns-3-dev/scratch
# Build directory: /usr/ns-3-dev/cmake-cache/scratch
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(ctest-scratch_evalvid_lte_aval_x2 "ns3.39-evalvid_lte_aval_x2-optimized")
set_tests_properties(ctest-scratch_evalvid_lte_aval_x2 PROPERTIES  WORKING_DIRECTORY "/usr/ns-3-dev/build/scratch/" _BACKTRACE_TRIPLES "/usr/ns-3-dev/build-support/macros-and-definitions.cmake;1584;add_test;/usr/ns-3-dev/build-support/macros-and-definitions.cmake;1659;set_runtime_outputdirectory;/usr/ns-3-dev/scratch/CMakeLists.txt;57;build_exec;/usr/ns-3-dev/scratch/CMakeLists.txt;69;create_scratch;/usr/ns-3-dev/scratch/CMakeLists.txt;0;")
add_test(ctest-scratch_scratch-simulator "ns3.39-scratch-simulator-optimized")
set_tests_properties(ctest-scratch_scratch-simulator PROPERTIES  WORKING_DIRECTORY "/usr/ns-3-dev/build/scratch/" _BACKTRACE_TRIPLES "/usr/ns-3-dev/build-support/macros-and-definitions.cmake;1584;add_test;/usr/ns-3-dev/build-support/macros-and-definitions.cmake;1659;set_runtime_outputdirectory;/usr/ns-3-dev/scratch/CMakeLists.txt;57;build_exec;/usr/ns-3-dev/scratch/CMakeLists.txt;69;create_scratch;/usr/ns-3-dev/scratch/CMakeLists.txt;0;")
add_test(ctest-scratch_subdir_scratch-subdir "ns3.39-scratch-subdir-optimized")
set_tests_properties(ctest-scratch_subdir_scratch-subdir PROPERTIES  WORKING_DIRECTORY "/usr/ns-3-dev/build/scratch/subdir/" _BACKTRACE_TRIPLES "/usr/ns-3-dev/build-support/macros-and-definitions.cmake;1584;add_test;/usr/ns-3-dev/build-support/macros-and-definitions.cmake;1659;set_runtime_outputdirectory;/usr/ns-3-dev/scratch/CMakeLists.txt;57;build_exec;/usr/ns-3-dev/scratch/CMakeLists.txt;99;create_scratch;/usr/ns-3-dev/scratch/CMakeLists.txt;0;")
subdirs("lte-sdn-evalvid")
subdirs("nested-subdir")
