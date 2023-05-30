#
#  Copyright (c) 2023 M4ximumpizza - All Rights Reserved.
#

include("${CMAKE_CURRENT_LIST_DIR}/configure.cmake")

include(CMakeParseArguments)

function(add_semver_file name)
  # Process arguments
  set(options METADATA_GIT)
  set(oneValueArgs)
  set(multiValueArgs PRERELEASE METADATA)
  cmake_parse_arguments(semver "${options}" "${oneValueArgs}"
                        "${multiValueArgs}" ${ARGN} )

  set(${name}_SEMVER_MAJOR ${${name}_VERSION_MAJOR})
  set(${name}_SEMVER_MINOR ${${name}_VERSION_MINOR})
  set(${name}_SEMVER_PATCH ${${name}_VERSION_PATCH})
  set(${name}_SEMVER_PRERELEASE)
  set(${name}_SEMVER_METADATA)
  
  if("${${name}_SEMVER_PATCH}" STREQUAL "")
    list(INSERT semver_PRERELEASE 0 "prerelease")
    set(${name}_SEMVER_PATCH 0)
  endif()

  list(JOIN semver_PRERELEASE "." ${name}_SEMVER_PRERELEASE)

  set(${name}_SEMVER_RELEASE 0)
  if(NOT semver_PRERELEASE)
    set(${name}_SEMVER_RELEASE 1)
  endif()
  set(${name}_SEMVER_INTEGER "${${name}_SEMVER_MAJOR}")
  math(EXPR ${name}_SEMVER_INTEGER "(${${name}_SEMVER_INTEGER})*1000+(${${name}_SEMVER_MINOR})")
  math(EXPR ${name}_SEMVER_INTEGER "(${${name}_SEMVER_INTEGER})*1000+(${${name}_SEMVER_PATCH})")
  math(EXPR ${name}_SEMVER_INTEGER "(${${name}_SEMVER_INTEGER})*10+(${${name}_SEMVER_RELEASE})")

  set(semver_env
    ${name}_SEMVER_MAJOR
    ${name}_SEMVER_MINOR
    ${name}_SEMVER_PATCH
    ${name}_SEMVER_PRERELEASE
    ${name}_SEMVER_METADATA
    ${name}_SEMVER_VERSION
    ${name}_SEMVER_INTEGER
  )

  configured_file_content_varonly(semver_content ${semver_env})

  set(configure_script_code)
  if(semver_METADATA_GIT)
    set(semver_extradeps "${CMAKE_CURRENT_BINARY_DIR}/gitmeta.version")
    string(APPEND configure_script_code "
include(\"${CMAKE_CURRENT_BINARY_DIR}/gitmeta.version\")\n
string(JOIN \".\" ${name}_SEMVER_METADATA \${GITMETA_METADATA} \${${name}_SEMVER_METADATA})
")
  endif()
  # add code to construct SEMVER_VERSION string 
  string(APPEND configure_script_code "
string(JOIN \".\" ${name}_SEMVER_VERSION
  \${${name}_SEMVER_MAJOR} \${${name}_SEMVER_MINOR} \${${name}_SEMVER_PATCH})
string(JOIN \"-\" ${name}_SEMVER_VERSION
  \${${name}_SEMVER_VERSION} \${${name}_SEMVER_PRERELEASE})
string(JOIN \"+\" ${name}_SEMVER_VERSION
  \${${name}_SEMVER_VERSION} \${${name}_SEMVER_METADATA})

message(STATUS \"${name} Version: \${${name}_SEMVER_VERSION}\")
  ")

  add_configured_file(${name}.version
    CONTENT "${semver_content}"
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${name}.version"
    ALWAYS
    EXTRA_DEPS ${semver_extradeps}
    VARIABLES ${semver_env}
  )

  if(semver_METADATA_GIT)
      #add_dependencies(configure-${name}.version configure-gitmeta.version)
  endif()
endfunction()
