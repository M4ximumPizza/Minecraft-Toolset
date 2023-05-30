#
#  Copyright (c) 2023 M4ximumpizza - All Rights Reserved.
#

macro(add_RunMC-Toolkit_test test)
  set(TEST_ARGS ${ARGN})
  set(test_dir "Run${test}")
  add_test(NAME Run.${test} COMMAND ${CMAKE_COMMAND}
    -DCMAKE_MODULE_PATH=${CMAKE_CURRENT_SOURCE_DIR}
    -DRunMC-Toolkit_SOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}/${test_dir}
    -DRunMC-Toolkit_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}/${test_dir}
    -DRunMC-Toolkit_EXE=$<TARGET_FILE:MC-Toolkit>
    ${TEST_ARGS}
    -P "${CMAKE_CURRENT_SOURCE_DIR}/${test_dir}/RunTest.cmake"
    )
endmacro()

add_RunMC-Toolkit_test(Main)
add_RunMC-Toolkit_test(Version)
add_RunMC-Toolkit_test(Help)
add_RunMC-Toolkit_test(ListKeys)
add_RunMC-Toolkit_test(RmKeys)
add_RunMC-Toolkit_test(DumpKey)
add_RunMC-Toolkit_test(WriteKey)
add_RunMC-Toolkit_test(Repair)
add_RunMC-Toolkit_test(Copyall)
