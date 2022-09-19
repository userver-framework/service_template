CMAKE_COMMON_FLAGS ?= -DUSERVER_OPEN_SOURCE_BUILD=1 -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
CMAKE_DEBUG_FLAGS ?= -DUSERVER_SANITIZE='addr ub'
CMAKE_RELEASE_FLAGS ?=
CMAKE_OS_FLAGS ?= -DUSERVER_FEATURE_CRYPTOPP_BLAKE2=0 -DUSERVER_FEATURE_REDIS_HI_MALLOC=1
NPROCS ?= $(shell nproc)

# NOTE: use Makefile.local for customization
-include Makefile.local

all: test-debug test-release

# Debug cmake configuration
build_debug/Makefile:
	@git submodule update --init
	@mkdir -p build_debug
	@cd build_debug && \
      cmake -DCMAKE_BUILD_TYPE=Debug $(CMAKE_COMMON_FLAGS) $(CMAKE_DEBUG_FLAGS) $(CMAKE_OS_FLAGS) $(CMAKE_OPTIONS) ..

# Release cmake configuration
build_release/Makefile:
	@git submodule update --init
	@mkdir -p build_release
	@cd build_release && \
      cmake -DCMAKE_BUILD_TYPE=Release $(CMAKE_COMMON_FLAGS) $(CMAKE_RELEASE_FLAGS) $(CMAKE_OS_FLAGS) $(CMAKE_OPTIONS) ..

# build using cmake
build-impl-%: build_%/Makefile
	@cmake --build build_$* -j $(NPROCS) --target service_template

# test
test-impl-%: build-impl-%
	@cmake --build build_$* -j $(NPROCS) --target service_template_unittest
	@cmake --build build_$* -j $(NPROCS) --target service_template_benchmark
	@cd build_$* && ((test -t 1 && GTEST_COLOR=1 PYTEST_ADDOPTS="--color=yes" ctest -V) || ctest -V)
	@pep8 tests

# testsuite service runner
service-impl-start-%: build-impl-%
	@cd ./build_$* && $(MAKE) start-service_template

# clean
clean-impl-%:
	cd build_$* && $(MAKE) clean

# dist-clean
.PHONY: dist-clean
dist-clean:
	@rm -rf build_*
	@rm -f ./configs/static_config.yaml

# format
.PHONY: format
format:
	@find src -name '*pp' -type f | xargs clang-format -i
	@find tests -name '*.py' -type f | xargs autopep8 -i

.PHONY: cmake-debug build-debug test-debug clean-debug cmake-release build-release test-release clean-release install install-debug

install: build-release
	@cd build_release && \
		cmake --install . -v --component service_template

install-debug: build-debug
	@cd build_debug && \
		cmake --install . -v --component service_template

# Hide target, use only in docker environment
--debug-start-in-docker: install-debug
	@/home/user/.local/bin/service_template \
		--config /home/user/.local/etc/service_template/static_config.yaml

# Hide target, use only in docker environment
--debug-start-in-docker-debug: install-debug
	@/home/user/.local/bin/service_template \
		--config /home/user/.local/etc/service_template/static_config.yaml

.PHONY: docker-cmake-debug docker-build-debug docker-test-debug docker-clean-debug docker-cmake-release docker-build-release docker-test-release docker-clean-release docker-install docker-install-debug docker-start-service-debug docker-start-service docker-clean-data

# Build and runs service in docker environment
docker-start-service:
	@docker-compose run -p 8080:8080 --rm service_template make -- --debug-start-in-docker

# Build and runs service in docker environment
docker-start-service-debug:
	@docker-compose run -p 8080:8080 --rm service_template make -- --debug-start-in-docker-debug

# Start targets makefile in docker environment
docker-impl-%:
	docker-compose run --rm service_template make $*

# Explicitly specifying the targets to help shell with completions
cmake-debug: build_debug/Makefile
cmake-release: build_release/Makefile

build-debug: build-impl-debug
build-release: build-impl-release

test-debug: test-impl-debug
test-release: test-impl-release

service-start-debug: service-impl-start-debug
service-start-release: service-impl-start-release

clean-debug: clean-impl-debug
clean-release: clean-impl-release

docker-cmake-debug: docker-impl-cmake-debug
docker-cmake-release: docker-impl-cmake-release

docker-build-debug: docker-impl-build-debug
docker-build-release: docker-impl-build-release

docker-test-debug: docker-impl-test-debug
docker-test-release: docker-impl-test-release

docker-clean-debug: docker-impl-clean-debug
docker-clean-release: docker-impl-clean-release

docker-install: docker-impl-install
docker-install-debug: docker-impl-install-debug
