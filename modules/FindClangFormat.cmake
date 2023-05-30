#
#  Copyright (c) 2023 M4ximumpizza - All Rights Reserved.
#

set(clang_format_names clang-format)

find_program(CLANG_FORMAT_EXECUTABLE
  NAMES ${clang_format_names}
  DOC "clang-format command line client"
)

unset(clang_format_names)

mark_as_advanced(CLANG_FORMAT_EXECUTABLE)

if(CLANG_FORMAT_EXECUTABLE)
  execute_process(COMMAND "${CLANG_FORMAT_EXECUTABLE}" -version
                  OUTPUT_VARIABLE clang_format_version_str
                  ERROR_QUIET
                  OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(clang_format_version_str MATCHES "^clang-format version ([0-9][0-9.]+)")
    set(CLANG_FORMAT_VERSION "${CMAKE_MATCH_1}")
  endif()

  unset(clang_format_version_str)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ClangFormat
  REQUIRED_VARS CLANG_FORMAT_EXECUTABLE
  VERSION_VAR CLANG_FORMAT_VERSION
)
