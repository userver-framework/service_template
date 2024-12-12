include_guard(GLOBAL)

function(download_userver)
  set(OPTIONS)
  set(ONE_VALUE_ARGS TRY_DIR VERSION)
  set(MULTI_VALUE_ARGS)
  cmake_parse_arguments(
      ARG "${OPTIONS}" "${ONE_VALUE_ARGS}" "${MULTI_VALUE_ARGS}" ${ARGN}
  )

  if(ARG_TRY_DIR AND EXISTS "${ARG_TRY_DIR}")
    message(STATUS "Using userver from ${ARG_TRY_DIR}")
    add_subdirectory("${ARG_TRY_DIR}")
    return()
  endif()

  if(NOT DEFINED ARG_VERSION)
    set(GIT_TAG develop)
  endif()

  include(get_cpm)
  CPMAddPackage(
      NAME userver
      GITHUB_REPOSITORY userver-framework/userver
      VERSION ${ARG_VERSION}
      GIT_TAG ${ARG_GIT_TAG}
      ${ARG_UNPARSED_ARGUMENTS}
  )
endfunction()
