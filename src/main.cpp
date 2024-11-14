#include <userver/clients/dns/component.hpp>
#include <userver/clients/http/component.hpp>
#include <userver/components/minimal_server_component_list.hpp>
#include <userver/congestion_control/component.hpp>
#include <userver/server/handlers/ping.hpp>
#include <userver/server/handlers/tests_control.hpp>
#include <userver/storages/mongo/component.hpp>
#include <userver/testsuite/testsuite_support.hpp>
#include <userver/ugrpc/client/client_factory_component.hpp>
#include <userver/ugrpc/client/common_component.hpp>
#include <userver/ugrpc/client/middlewares/deadline_propagation/component.hpp>
#include <userver/ugrpc/client/middlewares/log/component.hpp>
#include <userver/ugrpc/server/middlewares/congestion_control/component.hpp>
#include <userver/ugrpc/server/middlewares/deadline_propagation/component.hpp>
#include <userver/ugrpc/server/middlewares/log/component.hpp>
#include <userver/ugrpc/server/server_component.hpp>
#include <userver/utils/daemon_run.hpp>

#include "hello.hpp"
#include "hello_client.hpp"

int main(int argc, char* argv[]) {
  auto component_list = 
      userver::components::MinimalServerComponentList()
          .Append<userver::congestion_control::Component>()
          .Append<userver::ugrpc::server::ServerComponent>()
          .Append<userver::ugrpc::server::middlewares::congestion_control::Component>()
          .Append<userver::ugrpc::server::middlewares::deadline_propagation::Component>()
          .Append<userver::ugrpc::server::middlewares::log::Component>()
          .Append<userver::ugrpc::client::CommonComponent>()
          .Append<userver::ugrpc::client::ClientFactoryComponent>()
          .Append<userver::ugrpc::client::middlewares::deadline_propagation::Component>()
          .Append<userver::ugrpc::client::middlewares::log::Component>()
          .Append<userver::server::handlers::Ping>()
          .Append<userver::components::TestsuiteSupport>()
          .Append<userver::components::HttpClient>()
          .Append<userver::server::handlers::TestsControl>()
          .Append<userver::clients::dns::Component>()
          .Append<userver::components::Mongo>("mongo-db-1");

  mongo_grpc_service_template::AppendHello(component_list);
  mongo_grpc_service_template::AppendHelloClient(component_list);

  return userver::utils::DaemonMain(argc, argv, component_list);
}
