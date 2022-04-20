cmake_minimum_required(VERSION 3.12)
project(service_template CXX)

include(third_party/userver/cmake/SetupEnvironment.cmake)
add_subdirectory(third_party/userver)


# Common sources
add_library(${PROJECT_NAME}_objs OBJECT
    src/hello.hpp
    src/hello.cpp
)
target_link_libraries(${PROJECT_NAME}_objs userver-core)


# The Service
add_executable(${PROJECT_NAME} src/main.cpp)
target_link_libraries(${PROJECT_NAME} ${PROJECT_NAME}_objs)


# Unit Tests
add_executable(${PROJECT_NAME}_unittest
    src/hello_test.cpp
)
target_link_libraries(${PROJECT_NAME}_unittest ${PROJECT_NAME}_objs userver-utest)
add_google_tests(${PROJECT_NAME}_unittest)


# Functional Tests
add_subdirectory(tests)
