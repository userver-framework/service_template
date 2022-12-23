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

cmake-debug cmake-release: cmake-%: build_%/Makefile

# build using cmake
build-debug build-release: build-%: cmake-%
	@cmake --build build_$* -j $(NPROCS) --target service_template

# test
test-debug test-release: test-%: build-%
	@cmake --build build_$* -j $(NPROCS) --target service_template_unittest
	@cmake --build build_$* -j $(NPROCS) --target service_template_benchmark
	@cd build_$* && ((test -t 1 && GTEST_COLOR=1 PYTEST_ADDOPTS="--color=yes" ctest -V) || ctest -V)
	@pep8 tests

# testsuite service runner
service-start-debug service-start-release: service-start-%: build-%
	@cd ./build_$* && $(MAKE) start-service_template

# clean
clean-debug clean-release: clean-%:
	cd build_$* && $(MAKE) clean

install-debug install-release: install-%: build-%
	@cd build_$* && \
		cmake --install . -v --component service_template

install: install-release

.PHONY: cmake-debug build-debug test-debug clean-debug install-debug
.PHONY: cmake-release build-release test-release clean-release install-release install


dist-clean:
	@rm -rf build_*
	@rm -f ./configs/static_config.yaml

format:
	@find src -name '*pp' -type f | xargs clang-format -i
	@find tests -name '*.py' -type f | xargs autopep8 -i

.PHONY: dist-clean format


# Hide target, use only in docker environment
--in-docker-start-debug --in-docker-start-release: --in-docker-start-%: install-%
	@/home/user/.local/bin/service_template \
		--config /home/user/.local/etc/service_template/static_config.yaml

.PHONY: docker-cmake-debug docker-build-debug docker-test-debug docker-clean-debug docker-install-debug
.PHONY: docker-cmake-release docker-build-release docker-test-release docker-clean-release docker-install-release docker-start-service-debug docker-start-service

# Build and runs service in docker environment
docker-start-service-debug docker-start-service-release: docker-start-service-%:
	@docker-compose run -p 8080:8080 --rm service_template $(MAKE) -- --in-docker-start-$*

# Start targets makefile in docker environment
docker-cmake-debug docker-build-debug docker-test-debug docker-clean-debug docker-install-debug docker-cmake-release docker-build-release docker-test-release docker-clean-release docker-install-release: docker-%
	docker-compose run --rm service_template $(MAKE) $*
