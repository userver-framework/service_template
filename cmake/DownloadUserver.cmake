include_guard(GLOBAL)

function(download_userver)
  set(OPTIONS)
  set(ONE_VALUE_ARGS TRY_DIR)
  set(MULTI_VALUE_ARGS)
  cmake_parse_arguments(
      ARG "${OPTIONS}" "${ONE_VALUE_ARGS}" "${MULTI_VALUE_ARGS}" ${ARGN}
  )

  if(ARG_TRY_DIR AND EXISTS "${ARG_TRY_DIR}")
    message(STATUS "Using userver from ${ARG_TRY_DIR}")
    add_subdirectory("${ARG_TRY_DIR}")
    return()
  endif()

  include(get_cpm)
  CPMAddPackage(
      NAME userver
      ${ARG_UNPARSED_ARGUMENTS}
  )
endfunction()
