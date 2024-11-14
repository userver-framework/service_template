#pragma once

#include <handlers/hello_client.usrv.pb.hpp>
#include <userver/components/component_list.hpp>
#include <userver/components/loggable_component_base.hpp>
#include <userver/components/component.hpp>
#include <userver/ugrpc/client/client_factory_component.hpp>

namespace mongo_grpc_service_template {

class HelloClient final : public userver::components::LoggableComponentBase {
 public:
  static constexpr std::string_view kName = "hello-client";

  HelloClient(const userver::components::ComponentConfig& config,
              const userver::components::ComponentContext& component_context)
      : userver::components::LoggableComponentBase(config, component_context),
        client_factory_(
            component_context
                .FindComponent<userver::ugrpc::client::ClientFactoryComponent>()
                .GetFactory()),
        // The client needs a fixed endpoint
        client_(client_factory_.MakeClient<handlers::api::HelloServiceClient>(
            "hello-client", config["endpoint"].As<std::string>())) {}

  std::string SayHello(std::string name);

  static userver::yaml_config::Schema GetStaticConfigSchema();

 private:
  userver::ugrpc::client::ClientFactory& client_factory_;
  handlers::api::HelloServiceClient client_;
};

void AppendHelloClient(userver::components::ComponentList& component_list);


}  // namespace mongo_grpc_service_template

template <>
inline constexpr bool userver::components::kHasValidate<mongo_grpc_service_template::HelloClient> = true;
