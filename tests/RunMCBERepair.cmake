#
#  Copyright (c) 2023 M4ximumpizza - All Rights Reserved.
#

function(run_MC-Toolkit test)
  set(top_src "${RunMC-Toolkit_SOURCE_DIR}")
  set(top_bin "${RunMC-Toolkit_BINARY_DIR}")
  set(test_args "${ARGN}")
  if(EXISTS ${top_src}/${test}-result.txt)
    file(READ ${top_src}/${test}-result.txt expect_result)
    string(REGEX REPLACE "\n+$" "" expect_result "${expect_result}")
  else()
    set(expect_result 0)
  endif()

  foreach(o out err)
    if(EXISTS ${top_src}/${test}-std${o}.txt)
      file(READ ${top_src}/${test}-std${o}.txt expect_std${o})
      string(REGEX REPLACE "\n+$" "" expect_std${o} "${expect_std${o}}")
    else()
      unset(expect_std${o})
    endif()
  endforeach()
  if (NOT expect_stderr)
    if (NOT RunMC-Toolkit_DEFAULT_stderr)
      set(RunMC-Toolkit_DEFAULT_stderr "^$")
    endif()
    set(expect_stderr ${RunMC-Toolkit_DEFAULT_stderr})
  endif()

  if (NOT RunMC-Toolkit_TEST_SOURCE_DIR)
    set(RunMC-Toolkit_TEST_SOURCE_DIR "${top_src}")
  endif()
  if(NOT RunMC-Toolkit_TEST_BINARY_DIR)
    set(RunMC-Toolkit_TEST_BINARY_DIR "${top_bin}/${test}-build")
  endif()
  if(NOT RunMC-Toolkit_TEST_NO_CLEAN)
    file(REMOVE_RECURSE "${RunMC-Toolkit_TEST_BINARY_DIR}")
  endif()
  file(MAKE_DIRECTORY "${RunMC-Toolkit_TEST_BINARY_DIR}")
  if(NOT DEFINED RunMC-Toolkit_TEST_OPTIONS)
    set(RunMC-Toolkit_TEST_OPTIONS "")
  endif()
  if(RunMC-Toolkit_TEST_OUTPUT_MERGE)
    set(actual_stderr_var actual_stdout)
    set(actual_stderr "")
  else()
    set(actual_stderr_var actual_stderr)
  endif()
  if(DEFINED RunMC-Toolkit_TEST_TIMEOUT)
    set(maybe_timeout TIMEOUT ${RunMC-Toolkit_TEST_TIMEOUT})
  else()
    set(maybe_timeout "")
  endif()
  if(EXISTS ${top_src}/${test}-stdin.txt)
    set(maybe_input_file INPUT_FILE ${top_src}/${test}-stdin.txt)
  else()
    set(maybe_input_file "")
  endif()
  if(NOT RunMC-Toolkit_TEST_COMMAND)
    set(RunMC-Toolkit_TEST_COMMAND "${RunMC-Toolkit_EXE}" ${test_args})
  endif()
  if(NOT RunMC-Toolkit_TEST_COMMAND_WORKING_DIRECTORY)
    set(RunMC-Toolkit_TEST_COMMAND_WORKING_DIRECTORY "${RunMC-Toolkit_TEST_BINARY_DIR}")
  endif()
  if( ${ARGC} GREATER 3 AND "${ARGV3}" STREQUAL "" )
    # work around a CMAKE limitation for one of our tests
    list(REMOVE_AT ARGV 0)
    list(REMOVE_AT ARGV 0)
    list(REMOVE_AT ARGV 0)
    list(REMOVE_AT ARGV 0)
    execute_process(
      COMMAND "${RunMC-Toolkit_EXE}" "${ARGV1}" "${ARGV2}" "" ${ARGV}
      WORKING_DIRECTORY "${RunMC-Toolkit_TEST_COMMAND_WORKING_DIRECTORY}"
      OUTPUT_VARIABLE actual_stdout
      ERROR_VARIABLE ${actual_stderr_var}
      RESULT_VARIABLE actual_result
      ENCODING UTF8
      ${maybe_timeout}
      ${maybe_input_file}
      )
  else()
    execute_process(
      COMMAND ${RunMC-Toolkit_TEST_COMMAND}
      WORKING_DIRECTORY "${RunMC-Toolkit_TEST_COMMAND_WORKING_DIRECTORY}"
      OUTPUT_VARIABLE actual_stdout
      ERROR_VARIABLE ${actual_stderr_var}
      RESULT_VARIABLE actual_result
      ENCODING UTF8
      ${maybe_timeout}
      ${maybe_input_file}
      )
  endif()
  set(msg "")
  if(NOT "${actual_result}" MATCHES "${expect_result}")
    string(APPEND msg "Result is [${actual_result}], not [${expect_result}].\n")
  endif()

  foreach(o out err)
    string(REGEX REPLACE "\r\n" "\n" actual_std${o} "${actual_std${o}}")
    string(REGEX REPLACE "\n+$" "" actual_std${o} "${actual_std${o}}")
    set(expect_${o} "")
    if(DEFINED expect_std${o})
      if(NOT "${actual_std${o}}" MATCHES "${expect_std${o}}")
        string(REGEX REPLACE "\n" "\n expect-${o}> " expect_${o}
          " expect-${o}> ${expect_std${o}}")
        set(expect_${o} "Expected std${o} to match:\n${expect_${o}}\n")
        string(APPEND msg "std${o} does not match that expected.\n")
      endif()
    endif()
  endforeach()
  unset(RunMC-Toolkit_TEST_FAILED)
  include(${top_src}/${test}-check.cmake OPTIONAL)

  if(RunMC-Toolkit_TEST_FAILED)
    set(msg "${RunMC-Toolkit_TEST_FAILED}\n${msg}")
  endif()
  if(msg)
    string(REPLACE ";" "\" \"" command "\"${RunMC-Toolkit_TEST_COMMAND}\"")
    string(APPEND msg "Command was:\n command> ${command}\n")
  endif()
  if(msg)
    string(REGEX REPLACE "\n" "\n actual-out> " actual_out " actual-out> ${actual_stdout}")
    string(REGEX REPLACE "\n" "\n actual-err> " actual_err " actual-err> ${actual_stderr}")
    message(SEND_ERROR "${test} - FAILED:\n"
      "${msg}"
      "${expect_out}"
      "Actual stdout:\n${actual_out}\n"
      "${expect_err}"
      "Actual stderr:\n${actual_err}\n"
    )
  else()
    message(STATUS "${test} - PASSED")
  endif()
endfunction()

function(extract_world world_dir mcworld)
  file(REMOVE_RECURSE "${world_dir}")
  file(MAKE_DIRECTORY "${world_dir}")  
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E tar x "${mcworld}"
    WORKING_DIRECTORY "${world_dir}"
  )
endfunction()
