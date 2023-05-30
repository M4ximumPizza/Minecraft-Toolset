#
#  Copyright (c) 2023 M4ximumpizza - All Rights Reserved.
#

set(gcovr_names gcovr)

find_program(GCOVR_EXECUTABLE
  NAMES ${gcovr_names}
  DOC "gcovr command line client"
)

unset(gcovr_names)

mark_as_advanced(GCOVR_EXECUTABLE)

if(GCOVR_EXECUTABLE)
  execute_process(COMMAND "${GCOVR_EXECUTABLE}" --version
                  OUTPUT_VARIABLE gcovr_version_str
                  ERROR_QUIET
                  OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(gcovr_version_str MATCHES "^gcovr ([0-9][0-9.]+)")
    set(GCOVR_VERSION "${CMAKE_MATCH_1}")
  endif()

  unset(gcovr_version_str)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Gcovr
  REQUIRED_VARS GCOVR_EXECUTABLE
  VERSION_VAR GCOVR_VERSION
)
