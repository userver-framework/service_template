SERVICE_ROOTDIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
SERVICE_NAME := service_template

CMAKE_COMMON_FLAGS ?= -DOPEN_SOURCE_BUILD=1 -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
CMAKE_DEBUG_FLAGS ?= -DSANITIZE='addr ub'
CMAKE_RELESEAZE_FLAGS ?=
CMAKE_OS_FLAGS ?= -DUSERVER_FEATURE_CRYPTOPP_BLAKE2=0 -DUSERVER_FEATURE_REDIS_HI_MALLOC=1
NPROCS ?= $(shell nproc)

# NOTE: use Makefile.local for customization
-include $(SERVICE_ROOTDIR)/Makefile.local

# Debug cmake configuration
$(SERVICE_ROOTDIR)/build_debug/Makefile:
	@echo "Makefile: CC = ${CC} CXX = ${CXX}"
	@mkdir -p $(DEBUG_BUILDDIR)
	@cd $(DEBUG_BUILDDIR) && \
      cmake -DCMAKE_BUILD_TYPE=Debug $(CMAKE_COMMON_FLAGS) $(CMAKE_DEBUG_FLAGS) $(CMAKE_OS_FLAGS) $(CMAKE_OPTIONS) $(SERVICE_ROOTDIR)

# Release cmake configuration
$(SERVICE_ROOTDIR)/build_release/Makefile:
	@echo "Makefile: CC = ${CC} CXX = ${CXX}"
	@mkdir -p $(RELEASE_BUILDDIR)
	@cd $(RELEASE_BUILDDIR) && \
      cmake -DCMAKE_BUILD_TYPE=Release $(CMAKE_COMMON_FLAGS) $(CMAKE_RELESEAZE_FLAGS) $(CMAKE_OS_FLAGS) $(CMAKE_OPTIONS) $(SERVICE_ROOTDIR)

# virtualenv setup for running pytests
$(SERVICE_ROOTDIR)/build_%/tests/venv/pyvenv.cfg: $(SERVICE_ROOTDIR)/build_%/Makefile
	@cmake --build $(SERVICE_ROOTDIR)/build_$* -j$(NPROCS) --target testsuite-venv

# build using cmake
build-impl-%: $(SERVICE_ROOTDIR)/build_%/Makefile
	@cmake --build $(SERVICE_ROOTDIR)/build_$* -j$(NPROCS) --target $(SERVICE_NAME)

# test
test-impl-%: build-impl-% $(SERVICE_ROOTDIR)/build_%/tests/venv/pyvenv.cfg
	@cd tests && \
        $(SERVICE_ROOTDIR)/build_$*/tests/venv/bin/pytest --build-dir=$(SERVICE_ROOTDIR)/build_$*

# clean
clean-%:
	cd $* && $(MAKE) clean

# dist-clean
.PHONY: dist-clean
dist-clean:
	@rm -rf build_*

# Helping shell with completitions:
.PHONY: cmake-debug build-debug test-debug cmake-release build-release test-release

cmake-debug: $(SERVICE_ROOTDIR)/build_debug/Makefile
cmake-release: $(SERVICE_ROOTDIR)/build_release/Makefile

build-debug: build-impl-debug
build-release: build-impl-release

test-debug: test-impl-debug
test-release: test-impl-release
