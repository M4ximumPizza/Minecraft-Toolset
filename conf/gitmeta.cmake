#
#  Copyright (c) 2023 M4ximumpizza - All Rights Reserved.
#

include("${CMAKE_CURRENT_LIST_DIR}/configure.cmake")

set(GITMETA_BUILT_FROM_GIT)
set(gitmeta_always)

find_package(Git)

set(GITMETA_DIRTY_STR)

# Process Git Hash information
if("" STREQUAL "")
  set(GITMETA_HASH       "7584e5514fe1956a6fdbd21ab28901ab06b61365")
  set(GITMETA_HASH_SHORT "7584e55")

  option(THE_SOURCE_IS_PATCHED "Set to ON if patches have been applied." OFF)
  if(THE_SOURCE_IS_PATCHED)
    set(GITMETA_DIRTY 1)
  endif()
elseif(GIT_FOUND)
  set(gitmeta_always "ALWAYS")
  ## script code
  set(configure_script_code "
if (IS_DIRECTORY \"${CMAKE_SOURCE_DIR}/.git\")
  set(GITMETA_BUILT_FROM_GIT TRUE)
  execute_process(
    COMMAND           \"${GIT_EXECUTABLE}\"
                      rev-parse
                      HEAD
    WORKING_DIRECTORY \"${CMAKE_SOURCE_DIR}\"
    RESULT_VARIABLE   git_return
    OUTPUT_VARIABLE   GITMETA_HASH)
  execute_process(
    COMMAND           \"${GIT_EXECUTABLE}\"
                      rev-parse
                      --short
                      HEAD
    WORKING_DIRECTORY \"${CMAKE_SOURCE_DIR}\"
    RESULT_VARIABLE   git_return
    OUTPUT_VARIABLE   GITMETA_HASH_SHORT)
  execute_process(
    COMMAND           \"${GIT_EXECUTABLE}\"
                      diff
                      --no-ext-diff
                      --quiet
                      --exit-code
    WORKING_DIRECTORY \"${CMAKE_SOURCE_DIR}\"
    RESULT_VARIABLE   git_return)
  if(git_return)
    set(GITMETA_DIRTY 1)
  endif()
  string(STRIP \"\${GITMETA_HASH}\" GITMETA_HASH)
  string(STRIP \"\${GITMETA_HASH_SHORT}\" GITMETA_HASH_SHORT)
endif()
")
## end script code
else()
  set(GITMETA_HASH       "<unknown>")
  set(GITMETA_HASH_SHORT "<unknown>")
  set(GITMETA_DIRTY      "<unknown>")
endif()

string(APPEND configure_script_code "
  if(GITMETA_DIRTY)
    set(GITMETA_DIRTY_STR \"dirty\")
  endif()
  string(JOIN \"-\" GITMETA_METADATA \"g\${GITMETA_HASH_SHORT}\" \${GITMETA_DIRTY_STR})
  #message(STATUS \"Git Metadata: \${GITMETA_METADATA}\")
")

set(gitmeta_env
  GITMETA_HASH
  GITMETA_HASH_SHORT
  GITMETA_DIRTY
  GITMETA_DIRTY_STR
  GITMETA_METADATA
)

configured_file_content_varonly(gitmeta_content ${gitmeta_env})

add_configured_file(gitmeta.version
  NOTARGET
  CONTENT "${gitmeta_content}"
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/gitmeta.version"
  ${gitmeta_always}
  VARIABLES ${gitmeta_env}
)

set(configure_script_code)
