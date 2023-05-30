#
#  Copyright (c) 2023 M4ximumpizza - All Rights Reserved.
#

set(clang_tidy_names clang-tidy)

find_program(CLANG_TIDY_EXECUTABLE
  NAMES ${clang_tidy_names}
  DOC "clang-tidy command line client"
)

unset(clang_tidy_names)

mark_as_advanced(CLANG_TIDY_EXECUTABLE)

if(CLANG_TIDY_EXECUTABLE)
  execute_process(COMMAND "${CLANG_TIDY_EXECUTABLE}" -version
                  OUTPUT_VARIABLE clang_tidy_version_str
                  ERROR_QUIET
                  OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(clang_tidy_version_str MATCHES "version ([0-9][0-9.]+)")
    set(CLANG_TIDY_VERSION "${CMAKE_MATCH_1}")
  endif()

  unset(clang_tidy_version_str)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ClangTidy
  REQUIRED_VARS CLANG_TIDY_EXECUTABLE
  VERSION_VAR CLANG_TIDY_VERSION
)
