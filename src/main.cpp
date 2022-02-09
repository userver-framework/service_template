#include <userver/components/minimal_server_component_list.hpp>
#include <userver/server/handlers/ping.hpp>
#include <userver/utils/daemon_run.hpp>

#include "hello.hpp"

int main(int argc, char *argv[]) {
  auto component_list = userver::components::MinimalServerComponentList()
                            .Append<userver::server::handlers::Ping>();
  service_template::AppendHello(component_list);

  return userver::utils::DaemonMain(argc, argv, component_list);
}
