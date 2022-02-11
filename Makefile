SERVICE_ROOTDIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
SERVICE_NAME := service_template

DEBUG_BUILDDIR ?= $(SERVICE_ROOTDIR)/build_debug
RELEASE_BUILDDIR ?= $(SERVICE_ROOTDIR)/build_release
CMAKE_COMMON_FLAGS ?= -DOPEN_SOURCE_BUILD=1 -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
CMAKE_DEBUG_FLAGS ?= -DSANITIZE='addr ub'
CMAKE_RELESEAZE_FLAGS ?=
CMAKE_OS_FLAGS ?= -DUSERVER_FEATURE_CRYPTOPP_BLAKE2=0 -DUSERVER_FEATURE_REDIS_HI_MALLOC=1
NPROCS ?= $(shell nproc)

# NOTE: use Makefile.local for customization
-include $(SERVICE_ROOTDIR)/Makefile.local

.PHONY: clean
clean:
	@rm -rf $(DEBUG_BUILDDIR) $(RELEASE_BUILDDIR)

################################## Debug

$(DEBUG_BUILDDIR)/Makefile:
	@echo "Makefile: CC = ${CC} CXX = ${CXX}"
	@mkdir -p $(DEBUG_BUILDDIR)
	@cd $(DEBUG_BUILDDIR) && \
      cmake -DCMAKE_BUILD_TYPE=Debug $(CMAKE_COMMON_FLAGS) $(CMAKE_DEBUG_FLAGS) $(CMAKE_OS_FLAGS) $(CMAKE_OPTIONS) $(SERVICE_ROOTDIR)

.PHONY: cmake-debug
cmake-debug: $(DEBUG_BUILDDIR)/Makefile

$(DEBUG_BUILDDIR)/tests/venv/pyvenv.cfg:
	@cmake --build $(DEBUG_BUILDDIR) -j$(NPROCS) --target testsuite-venv

.PHONY: venv-debug
venv-debug: $(DEBUG_BUILDDIR)/tests/venv/pyvenv.cfg

.PHONY: build-debug
build-debug: cmake-debug
	@cmake --build $(DEBUG_BUILDDIR) -j$(NPROCS) --target $(SERVICE_NAME)

.PHONY: test-debug
test-debug: build-debug venv-debug
	@cd tests && \
        $(DEBUG_BUILDDIR)/tests/venv/bin/pytest --build-dir=$(DEBUG_BUILDDIR)


################################## Release

$(RELEASE_BUILDDIR)/Makefile:
	@echo "Makefile: CC = ${CC} CXX = ${CXX}"
	@mkdir -p $(RELEASE_BUILDDIR)
	@cd $(RELEASE_BUILDDIR) && \
      cmake -DCMAKE_BUILD_TYPE=Release $(CMAKE_COMMON_FLAGS) $(CMAKE_RELESEAZE_FLAGS) $(CMAKE_OS_FLAGS) $(CMAKE_OPTIONS) $(SERVICE_ROOTDIR)

.PHONY: cmake-release
cmake-release: $(RELEASE_BUILDDIR)/Makefile

$(RELEASE_BUILDDIR)/tests/venv/pyvenv.cfg:
	@cmake --build $(RELEASE_BUILDDIR) -j$(NPROCS) --target testsuite-venv

.PHONY: venv-release
venv-release: $(RELEASE_BUILDDIR)/tests/venv/pyvenv.cfg

.PHONY: build-release
build-release: cmake-release
	@cmake --build $(RELEASE_BUILDDIR) -j$(NPROCS) --target $(SERVICE_NAME)

.PHONY: test-release
test-release: build-release venv-release
	@cd tests && \
        $(RELEASE_BUILDDIR)/tests/venv/bin/pytest --build-dir=$(RELEASE_BUILDDIR)
