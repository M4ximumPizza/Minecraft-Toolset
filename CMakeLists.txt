#
# Copyright (c) 2023 M4ximumpizza - All Rights Reserved.
#

cmake_minimum_required(VERSION 3.12)
cmake_policy(SET CMP0048 NEW)
cmake_policy(SET CMP0074 NEW)

set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
  message(FATAL_ERROR "In-source builds not allowed. Please run CMake from the './build' directory. You may need to remove CMakeCache.txt.")
endif()

################################################################################
#  Project Configuration

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/modules")
set(CMAKE_BUILD_TYPE_INIT "RelWithDebInfo")
set_property(GLOBAL PROPERTY FIND_LIBRARY_USE_LIB64_PATHS ON)

################################################################################
# Init Project

project(MC-Toolkit VERSION 0.2
  DESCRIPTION "Minecraft Bedrock Utilities"
  HOMEPAGE_URL "https://github.com/reedacartwright/MC-Toolkit/"
  LANGUAGES CXX
)

## Enable Developer CMake Flags
include("conf/devopt.cmake")

# Gitmeta data and semantic versioning
include("conf/gitmeta.cmake")
include("conf/semver.cmake")

add_semver_file(${CMAKE_PROJECT_NAME} METADATA_GIT)

option(LEVELDB_BUILD_TESTS OFF)
option(LEVELDB_INSTALL OFF)
add_subdirectory(leveldb-mcpe)

# GOOGLE disables RTTI for leveldb so we will do the same
if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  # Disable RTTI.
  string(REGEX REPLACE "/GR" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /GR-")
else()
  # Disable RTTI.
  string(REGEX REPLACE "-frtti" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-rtti")
endif()

## Turn on unit and executable testing
enable_testing()
#include("conf/doctest.cmake")

set(pretest_all ALL)
if(DEVOPT_EXCLUDE_PRETEST_FROM_ALL)
  set(pretest_all)
endif()

add_custom_target(pretest ${pretest_all})
add_dependencies(pretest configure)

add_subdirectory(tests)

################################################################################
# Installation Information

string(TOLOWER ${CMAKE_PROJECT_NAME} basename_for_install)

set(CMAKE_DATA_DIR "share/${basename_for_install}" CACHE STRING
  "Install location for data (relative to prefix).")
set(CMAKE_DOC_DIR "doc/${basename_for_install}" CACHE STRING
  "Install location for documentation (relative to prefix).")
set(CMAKE_MAN_DIR "man" CACHE STRING
  "Install location for man pages (relative to prefix).")
mark_as_advanced(CMAKE_DATA_DIR CMAKE_DOC_DIR CMAKE_MAN_DIR)

install(FILES README.md LICENSE DESTINATION ${CMAKE_DOC_DIR})

################################################################################
# Building binary

add_executable(MC-Toolkit
  main.cpp
  listkeys.cpp
  rmkeys.cpp
  dumpkey.cpp
  writekey.cpp
  repair.cpp
  copyall.cpp
  db.hpp
  mcbekey.hpp
  perenc.hpp
  slurp.hpp
)
target_link_libraries(MC-Toolkit leveldb)
target_include_directories(MC-Toolkit PUBLIC "${CMAKE_CURRENT_BINARY_DIR}")
# Enable Warnings
target_compile_options(MC-Toolkit PUBLIC
  $<$<OR:$<CXX_COMPILER_ID:Clang>,$<CXX_COMPILER_ID:AppleClang>,$<CXX_COMPILER_ID:GNU>>:-Wall -Wextra>
     $<$<CXX_COMPILER_ID:MSVC>:/W4>)

add_dependencies(MC-Toolkit configure-version.h)

install(TARGETS MC-Toolkit RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")

# copy any dlls installed by vcpkg on windows
if(VCPKG_APPLOCAL_DEPS AND VCPKG_TARGET_TRIPLET MATCHES "windows|uwp")
  install(DIRECTORY $<TARGET_FILE_DIR:MC-Toolkit>/
    TYPE BIN FILES_MATCHING PATTERN "*.dll")
endif()

# developer tools
clang_format_target(MC-Toolkit)
clang_tidy_target(MC-Toolkit)

target_link_libraries(MC-Toolkit devopt_coverage)

# Setup a target that will build version.h.in -> version.h
set(configure_script_code "
include(\"${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.version\")\n
")
add_configured_file(version.h
    INPUT "${CMAKE_CURRENT_SOURCE_DIR}/version.h.in"
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/version.h"
    EXTRA_DEPS "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.version"
    VARIABLES ${CMAKE_PROJECT_NAME}_SEMVER_VERSION
              ${CMAKE_PROJECT_NAME}_SEMVER_INTEGER
              ${CMAKE_PROJECT_NAME}_SEMVER_MAJOR
              ${CMAKE_PROJECT_NAME}_SEMVER_MINOR
              ${CMAKE_PROJECT_NAME}_SEMVER_PATCH
)
add_dependencies(configure-version.h configure-${CMAKE_PROJECT_NAME}.version)
unset(configure_script_code)

# Add Project File for sublime
configure_file(${CMAKE_PROJECT_NAME}.sublime-project.in ${CMAKE_PROJECT_NAME}.sublime-project @ONLY)

################################################################################
# Packaging

include(InstallRequiredSystemLibraries)

set(CPACK_PACKAGE_VENDOR "Reed A. Cartwright, PhD")
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Commandline tools for Minecraft: Bedrock Edition.")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
set(MC-Toolkit_package_version
  ${MC-Toolkit_VERSION_MAJOR}
  ${MC-Toolkit_VERSION_MINOR}
  ${MC-Toolkit_VERSION_PATCH}
)

if("${MC-Toolkit_VERSION_PATCH}" STREQUAL "")
  list(APPEND MC-Toolkit_package_version "0-prerelease")
endif()

list(JOIN MC-Toolkit_package_version "." CPACK_PACKAGE_VERSION)

set(CPACK_PACKAGE_CHECKSUM "SHA256")

IF(WIN32 AND NOT UNIX)
  set(CPACK_GENERATOR "ZIP")
  set(CPACK_SOURCE_GENERATOR "ZIP")
ELSE()
  set(CPACK_GENERATOR "TGZ")
  set(CPACK_SOURCE_GENERATOR "TGZ")
ENDIF()

set(CPACK_SOURCE_IGNORE_FILES
  # Files specific to version control.
  "/\\\\.git/"
  "/\\\\.gitattributes$"
  "/\\\\.gitmodules$"
  "/\\\\.github/"
  "/\\\\.gitignore$"
  "/\\\\.hooks-config$"

  # Build directory contents
  "/\\\\build/.+"

  # Development
  "/\\\\.circleci/"
  "/\\\\.clang-format$"
  "/\\\\.clang-tidy$"
  "/\\\\.codecov.yml$"

  # Temporary files.
  "\\\\.swp$"
  "\\\\.#"
  "/#"
  "~$"
  )

include(CPack)