#include "hello.hpp"

#include <fmt/format.h>

#include <userver/formats/bson/inline.hpp>
#include <userver/storages/mongo/options.hpp>
#include <userver/storages/mongo/pool.hpp>
#include <userver/utils/assert.hpp>

namespace mongo_grpc_service_template {

Hello::SayHelloResult Hello::SayHello(CallContext& /*context*/,
                                      handlers::api::HelloRequest&& request) {
  auto name = request.name();

  auto user_type = UserType::kFirstTime;
  if (!name.empty()) {
    auto users = mongo_pool_->GetCollection("hello_users");
    auto result = users.FindAndModify(
      userver::formats::bson::MakeDoc("name", name),
      userver::formats::bson::MakeDoc("$inc", userver::formats::bson::MakeDoc("count", 1)),
      userver::storages::mongo::options::Upsert{}
    );

    if (result.ModifiedCount() > 0) {
      user_type = UserType::kKnown;
    }
  }
  if (name.substr(0, 5) == "mock_") {
    name = client_.SayHello(name.substr(5));
  }
  handlers::api::HelloResponse response;
  response.set_text(SayHelloTo(name, user_type));
  return response;
}

std::string SayHelloTo(std::string_view name, UserType type) {
  if (name.empty()) {
    name = "unknown user";
  }

  switch (type) {
    case UserType::kFirstTime:
      return fmt::format("Hello, {}!\n", name);
    case UserType::kKnown:
      return fmt::format("Hi again, {}!\n", name);
  }

  UASSERT(false);
}

void AppendHello(userver::components::ComponentList& component_list) {
  component_list.Append<Hello>();
}

} // namespace mongo_grpc_service_template
