include(UserverTestsuite)

userver_testsuite_add(
  NAME service_template-testsuite
  REQUIREMENTS ${CMAKE_CURRENT_SOURCE_DIR}/requirements.txt
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  PYTEST_ARGS
  --service-config=${CMAKE_SOURCE_DIR}/configs/static_config.yaml
  --service-source-dir=${CMAKE_SOURCE_DIR}
  --service-binary=${CMAKE_BINARY_DIR}/service_template
  --config-fallback=${CMAKE_SOURCE_DIR}/configs/dynamic_config_fallback.json
)
