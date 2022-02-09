#include "hello.hpp"

#include <userver/server/handlers/http_handler_base.hpp>

namespace service_template {

namespace {

class Hello final : public userver::server::handlers::HttpHandlerBase {
public:
  static constexpr std::string_view kName = "handler-hello";

  using HttpHandlerBase::HttpHandlerBase;

  std::string HandleRequestThrow(
      const userver::server::http::HttpRequest &,
      userver::server::request::RequestContext &) const override {
    return "Hello world!\n";
  }
};

} // namespace

void AppendHello(userver::components::ComponentList &component_list) {
  component_list.Append<Hello>();
}

} // namespace service_template
