CMAKE_COMMON_FLAGS ?= -DUSERVER_OPEN_SOURCE_BUILD=1 -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
CMAKE_DEBUG_FLAGS ?= -DUSERVER_SANITIZE='addr ub'
CMAKE_RELESEAZE_FLAGS ?=
CMAKE_OS_FLAGS ?= -DUSERVER_FEATURE_CRYPTOPP_BLAKE2=0 -DUSERVER_FEATURE_REDIS_HI_MALLOC=1
NPROCS ?= $(shell nproc)

# NOTE: use Makefile.local for customization
-include Makefile.local

all: test-debug test-release

# Debug cmake configuration
build_debug/Makefile:
	@mkdir -p build_debug
	@cd build_debug && \
      cmake -DCMAKE_BUILD_TYPE=Debug $(CMAKE_COMMON_FLAGS) $(CMAKE_DEBUG_FLAGS) $(CMAKE_OS_FLAGS) $(CMAKE_OPTIONS) ..

# Release cmake configuration
build_release/Makefile:
	@mkdir -p build_release
	@cd build_release && \
      cmake -DCMAKE_BUILD_TYPE=Release $(CMAKE_COMMON_FLAGS) $(CMAKE_RELESEAZE_FLAGS) $(CMAKE_OS_FLAGS) $(CMAKE_OPTIONS) ..

# build using cmake
build-impl-%: build_%/Makefile
	@cmake --build build_$* -j$(NPROCS) --target service_template

# test
test-impl-%: build-impl-%
	@cmake --build build_$* -j$(NPROCS) --target service_template_unittest
	@cd build_$* && ctest -V
	@pep8 tests

# clean
clean-impl-%:
	cd build_$* && $(MAKE) clean

# dist-clean
.PHONY: dist-clean
dist-clean:
	@rm -rf build_*

# format
.PHONY: format
format:
	@find src -name '*pp' -type f | xargs clang-format -i
	@find tests -name '*.py' -type f | xargs autopep8 -i

.PHONY: cmake-debug build-debug test-debug clean-debug cmake-release build-release test-release clean-release install

install: build-release
	@cd build_release && \
		cmake --install . -v --component service_template

# Explicitly specifying the targets to help shell with completitions
cmake-debug: build_debug/Makefile
cmake-release: build_release/Makefile

build-debug: build-impl-debug
build-release: build-impl-release

test-debug: test-impl-debug
test-release: test-impl-release

clean-debug: clean-impl-debug
clean-release: clean-impl-release
