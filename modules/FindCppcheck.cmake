#
#  Copyright (c) 2023 M4ximumpizza - All Rights Reserved.
#

set(cppcheck_names cppcheck)

find_program(CPPCHECK_EXECUTABLE
  NAMES ${cppcheck_names}
  DOC "cppcheck command line client"
)

unset(cppcheck_names)

mark_as_advanced(CPPCHECK_EXECUTABLE)

if(CPPCHECK_EXECUTABLE)
  execute_process(COMMAND "${CPPCHECK_EXECUTABLE}" --version
                  OUTPUT_VARIABLE cppcheck_version_str
                  ERROR_QUIET
                  OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(cppcheck_version_str MATCHES "^Cppcheck ([0-9][0-9.]+)")
    set(CPPCHECK_VERSION "${CMAKE_MATCH_1}")
  endif()

  unset(cppcheck_version_str)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Cppcheck
  REQUIRED_VARS CPPCHECK_EXECUTABLE
  VERSION_VAR CPPCHECK_VERSION
)
