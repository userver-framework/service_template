cmake_minimum_required(VERSION 3.12)
project(service-template CXX)

set(CMAKE_MODULE_PATH
  ${CMAKE_MODULE_PATH}
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/userver/cmake
)
include(SetupEnvironment)

set(USERVER_FEATURE_CRYPTOPP_BLAKE OFF CACHE BOOL "")
set(USERVER_FEATURE_CRYPTOPP_BASE64_URL OFF CACHE BOOL "")
set(USERVER_FEATURE_POSTGRESQL OFF CACHE BOOL "")
set(USERVER_FEATURE_MONGODB OFF CACHE BOOL "")
set(USERVER_FEATURE_GRPC OFF CACHE BOOL "")
add_subdirectory(third_party/userver)

# cmake --build . -j$(nproc) --target service-template

add_executable(${PROJECT_NAME}
    src/main.cpp
)
target_link_libraries(${PROJECT_NAME} userver-core)
