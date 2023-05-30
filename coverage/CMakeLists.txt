#
#  Copyright (c) 2023 M4ximumpizza - All Rights Reserved.
#

set(gcovr_html "${CMAKE_CURRENT_BINARY_DIR}/coverage.html")
set(gcovr_xml  "${CMAKE_CURRENT_BINARY_DIR}/cobertura.xml")
set(gcovr_exclude
  "${CMAKE_SOURCE_DIR}/leveldb-mcpe"
)

find_package(Gcovr)

# if gcovr was found add targets
#   make coverage_html
#   make coverage_xml
if(Gcovr_FOUND)
  foreach(pat IN LISTS gcovr_exclude)
    LIST(APPEND gcovr_exclude_ --exclude "${pat}")
  endforeach()

  add_custom_command(
    OUTPUT "${gcovr_html}" "${gcovr_html}.noexist"
    COMMAND "${GCOVR_EXECUTABLE}"
      --root "${CMAKE_SOURCE_DIR}"
      --delete
      --exclude-unreachable-branches
      --exclude-throw-branches
      ${gcovr_exclude_}
      --html-details
      --output "${gcovr_html}"
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
  )
  add_custom_target(coverage_html
    DEPENDS "${gcovr_html}"
  )

  add_custom_command(
    OUTPUT "${gcovr_xml}" "${gcovr_xml}.noexist"
    COMMAND "${GCOVR_EXECUTABLE}"
      --root "${CMAKE_SOURCE_DIR}"
      --delete
      --exclude-unreachable-branches
      --exclude-throw-branches      
      ${gcovr_exclude_}
      --xml
      --output "${gcovr_xml}"
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
  )

  add_custom_target(coverage_xml
    DEPENDS "${gcovr_xml}"
  )
endif()

# Create a script to download codecov.bash script
file(GENERATE OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/download_codecov.cmake" CONTENT "
file(DOWNLOAD https://codecov.io/bash \"${CMAKE_CURRENT_BINARY_DIR}/codecov.bash\")
")

# Add support for codecov.io
#   make upload_codecov
add_custom_command(
  OUTPUT codecov.bash
  COMMAND "${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_BINARY_DIR}/download_codecov.cmake"
)

add_custom_target(upload_codecov
  DEPENDS codecov.bash
  COMMAND rm -f "${gcovr_xml}"
  COMMAND bash "${CMAKE_CURRENT_BINARY_DIR}/codecov.bash"
)
