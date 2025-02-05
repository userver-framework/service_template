PROJECT_NAME = service_template
NPROCS ?= $(shell nproc)
CLANG_FORMAT ?= clang-format
DOCKER_COMPOSE ?= docker-compose
PRESETS ?= debug release debug-custom release-custom

.PHONY: all
all: test-debug test-release

# Run cmake
.PHONY: $(addprefix cmake-, $(PRESETS))
$(addprefix cmake-, $(PRESETS)): cmake-%:
	cmake --preset $*

$(addsuffix /CMakeCache.txt, $(addprefix build-, $(PRESETS))): build-%/CMakeCache.txt:
	$(MAKE) cmake-$*

# Build using cmake
.PHONY: $(addprefix build-, $(PRESETS))
$(addprefix build-, $(PRESETS)): build-%: build-%/CMakeCache.txt
	cmake --build build-$* -j $(NPROCS) --target $(PROJECT_NAME)

# Test
.PHONY: $(addprefix test-, $(PRESETS))
$(addprefix test-, $(PRESETS)): test-%: build-%/CMakeCache.txt
	cmake --build build-$* -j $(NPROCS)
	cd build-$* && ((test -t 1 && GTEST_COLOR=1 PYTEST_ADDOPTS="--color=yes" ctest -V) || ctest -V)
	pycodestyle tests

# Start the service (via testsuite service runner)
.PHONY: $(addprefix start-, $(PRESETS))
$(addprefix start-, $(PRESETS)): start-%:
	cmake --build build-$* -v --target start-$(PROJECT_NAME)

# Cleanup data
.PHONY: $(addprefix clean-, $(PRESETS))
$(addprefix clean-, $(PRESETS)): clean-%:
	cmake --build build-$* --target clean

.PHONY: dist-clean
dist-clean:
	rm -rf build*
	rm -rf tests/__pycache__/
	rm -rf tests/.pytest_cache/
	rm -rf .ccache
	rm -rf .vscode/.cache
	rm -rf .vscode/compile_commands.json

# Install
.PHONY: $(addprefix install-, $(PRESETS))
$(addprefix install-, $(PRESETS)): install-%: build-%
	cmake --install build-$* -v --component $(PROJECT_NAME)

.PHONY: install
install: install-release

# Format the sources
.PHONY: format
format:
	find src -name '*pp' -type f | xargs $(CLANG_FORMAT) -i
	find tests -name '*.py' -type f | xargs autopep8 -i

# Internal hidden targets that are used only in docker environment
.PHONY: $(addprefix --in-docker-start-, $(PRESETS))
$(addprefix --in-docker-start-, $(PRESETS)): --in-docker-start-%: install-%
	/home/user/.local/bin/$(PROJECT_NAME) \
		--config /home/user/.local/etc/$(PROJECT_NAME)/static_config.yaml \
		--config_vars /home/user/.local/etc/$(PROJECT_NAME)/config_vars.yaml

# Build and run service in docker environment
.PHONY: $(addprefix docker-start-, $(PRESETS))
$(addprefix docker-start-, $(PRESETS)): docker-start-%:
	$(DOCKER_COMPOSE) run -p 8080:8080 --rm $(PROJECT_NAME)-container make -- --in-docker-start-$*

# Start specific target in docker environment
.PHONY: $(addprefix docker-cmake-, $(PRESETS)) $(addprefix docker-build-, $(PRESETS)) $(addprefix docker-test-, $(PRESETS)) $(addprefix docker-clean-, $(PRESETS)) $(addprefix docker-install-, $(PRESETS))
$(addprefix docker-cmake-, $(PRESETS)) $(addprefix docker-build-, $(PRESETS)) $(addprefix docker-test-, $(PRESETS)) $(addprefix docker-clean-, $(PRESETS)) $(addprefix docker-install-, $(PRESETS)): docker-%:
	$(DOCKER_COMPOSE) run --rm $(PROJECT_NAME)-container make $*

# Stop docker container and cleanup data
.PHONY: docker-clean-data
docker-clean-data:
	$(DOCKER_COMPOSE) down -v
