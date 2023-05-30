#
#  Copyright (c) 2023 M4ximumpizza - All Rights Reserved.
#

#add_configured_file()
# inspired by https://github.com/Kitware/sprokit/

include(CMakeParseArguments)

if(NOT TARGET configure)
  add_custom_target(configure ALL)
endif()

function(_generate_configure_script script name source dest)
  # Construct a configuration script at generation time

  string(APPEND script_content "# Configuration script for building '${dest}' from '${source}'\n")   
  # Set variables
  foreach(arg IN LISTS ARGN)
    string(APPEND script_content "set(${arg} \"${${arg}}\")\n")
  endforeach()

  # add optional custom code
  string(APPEND script_content "${configure_script_code}")

  # Process template
  string(APPEND script_content "configure_file(\"${source}\" \"${dest}.temp\" @ONLY)\n")
  string(APPEND script_content "configure_file(\"${dest}.temp\" \"${dest}\" COPYONLY)\n")

  # Create file at generation time
  file(GENERATE OUTPUT "${script}" CONTENT "${script_content}")
endfunction()

function(add_configured_file name)
  # Process arguments
  set(options NOTARGET ALWAYS EXCLUDE_FROM_CONFIGURE)
  set(oneValueArgs INPUT OUTPUT CONTENT)
  set(multiValueArgs EXTRA_DEPS VARIABLES)
  cmake_parse_arguments(add_conf_file "${options}" "${oneValueArgs}"
                        "${multiValueArgs}" ${ARGN} )

  # if content is specified, use it.
  if(add_conf_file_CONTENT)
    set(add_conf_file_INPUT "${add_conf_file_OUTPUT}.in")

    file(GENERATE OUTPUT "${add_conf_file_INPUT}" CONTENT "${add_conf_file_CONTENT}")
  endif()

  # Write Script
  set(script "${CMAKE_CURRENT_BINARY_DIR}/configure.${name}.cmake")
  _generate_configure_script("${script}" "${name}"
    "${add_conf_file_INPUT}" "${add_conf_file_OUTPUT}"
    ${add_conf_file_VARIABLES}
  )

  # use fake file to force building if ALWAYS is requested
  if(add_conf_file_ALWAYS)
    set(output "${add_conf_file_OUTPUT}" "${add_conf_file_OUTPUT}.noexist")
  else()
    set(output "${add_conf_file_OUTPUT}")
  endif()

  # Command to create file
  add_custom_command(
    OUTPUT  ${output}
    COMMAND "${CMAKE_COMMAND}" -P "${script}"
    MAIN_DEPENDENCY "${add_conf_file_INPUT}"
    DEPENDS "${add_conf_file_INPUT}"
            "${script}"
            ${add_conf_file_EXTRA_DEPS}
    WORKING_DIRECTORY
            "${CMAKE_CURRENT_BINARY_DIR}"
    COMMENT "Configuring: ${name}"
  )


  if(NOT add_conf_file_NOTARGET)
    # Custom Target and Properties
    add_custom_target(configure-${name}
      DEPENDS "${add_conf_file_OUTPUT}"
      SOURCES "${add_conf_file_INPUT}"
    )

    if(NOT add_conf_file_EXCLUDE_FROM_CONFIGURE)
      add_dependencies(configure configure-${name})
    endif()
  endif()
  source_group("Configured Files" FILES "${add_conf_file_INPUT}")

  set_property(DIRECTORY APPEND PROPERTY
    ADDITIONAL_MAKE_CLEAN_FILES "${script}" "${add_conf_file_OUTPUT}.temp")

endfunction()

# create an @ONLY content template
macro(configured_file_content_varonly var)
  set(${var} "")
  foreach(arg ${ARGN})
    string(APPEND ${var} "set(${arg} \"@${arg}@\")\n")
  endforeach()
endmacro()
