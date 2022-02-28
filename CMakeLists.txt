cmake_minimum_required(VERSION 3.12)
project(service_template CXX)

include(third_party/userver/cmake/SetupEnvironment.cmake)
add_subdirectory(third_party/userver)

add_executable(${PROJECT_NAME}
    src/hello.hpp
    src/hello.cpp
    src/main.cpp
)
target_link_libraries(${PROJECT_NAME} userver-core)

add_subdirectory(tests)
