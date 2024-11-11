# service_template

Template of a C++ service that uses [userver framework](https://github.com/userver-framework/userver).


## Download and Build

To create your own userver-based service follow the following steps:

1. Press the green "Use this template button" at the top of this github page
2. Clone the service `git clone your-service-repo && cd your-service-repo && git submodule update --init`
3. Give a proper name to your service and replace all the occurences of "service_template" string with that name
4. Feel free to tweak, adjust or fully rewrite the source code of your service.


## Makefile

Makefile contains typicaly useful targets for development:

* `make build-debug` - debug build of the service with all the assertions and sanitizers enabled
* `make build-release` - release build of the service with LTO
* `make test-debug` - does a `make build-debug` and runs all the tests on the result
* `make test-release` - does a `make build-release` and runs all the tests on the result
* `make start-debug` - builds the service in debug mode and starts it
* `make start-release` - builds the service in release mode and starts it
* `make` or `make all` - builds and runs all the tests in release and debug modes
* `make format` - autoformat all the C++ and Python sources
* `make clean-` - cleans the object files
* `make dist-clean` - clean all, including the CMake cached configurations
* `make install` - does a `make build-release` and run install in directory set in environment `PREFIX`
* `make install-debug` - does a `make build-debug` and runs install in directory set in environment `PREFIX`
* `make docker-COMMAND` - run `make COMMAND` in docker environment
* `make docker-build-debug` - debug build of the service with all the assertions and sanitizers enabled in docker environment
* `make docker-test-debug` - does a `make build-debug` and runs all the tests on the result in docker environment
* `make docker-start-release` - does a `make install-release` and runs service in docker environment
* `make docker-start-debug` - does a `make install-debug` and runs service in docker environment
* `make docker-clean-data` - stop docker containers

Edit `Makefile.local` to change the default configuration and build options.


## License

The original template is distributed under the [Apache-2.0 License](https://github.com/userver-framework/userver/blob/develop/LICENSE)
and [CLA](https://github.com/userver-framework/userver/blob/develop/CONTRIBUTING.md). Services based on the template may change
the license and CLA.
