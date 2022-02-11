include(CTest)

find_program(TESTSUITE_VIRTUALENV virtualenv)

add_custom_command(
  OUTPUT venv
  COMMAND ${TESTSUITE_VIRTUALENV} venv --python=${PYTHON}
)
add_custom_command(
  OUTPUT venv-requirements.stamp
  DEPENDS venv requirements.txt
  COMMAND
  ${CMAKE_CURRENT_BINARY_DIR}/venv/bin/pip install -U -r
  ${CMAKE_CURRENT_SOURCE_DIR}/requirements.txt
  COMMAND touch venv-requirements.stamp
)

add_custom_target(
  testsuite-venv
  COMMENT "Creating testsuite virtualenv"
  DEPENDS venv-requirements.stamp
)

add_test(
  NAME sample_project-testsuite
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/venv/bin/pytest
  -vv --build-dir=${CMAKE_BINARY_DIR}
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
