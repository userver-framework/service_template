cmake_minimum_required(VERSION 3.12)
project(service_template CXX)

set(CMAKE_MODULE_PATH
  ${CMAKE_MODULE_PATH}
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/userver/cmake
)
include(SetupEnvironment)

add_subdirectory(third_party/userver)

add_executable(${PROJECT_NAME}
    src/hello.hpp
    src/hello.cpp
    src/main.cpp
)
target_link_libraries(${PROJECT_NAME} userver-core)

add_subdirectory(tests)
