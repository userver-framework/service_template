#include "hello.hpp"

#include <benchmark/benchmark.h>
#include <userver/engine/run_standalone.hpp>

void HelloBenchmark(benchmark::State& state) {
  userver::engine::RunStandalone([&] {
    constexpr std::string_view kNames[] = {"userver", "is", "awesome", "!"};
    std::uint64_t i = 0;

    for (auto _ : state) {
      const auto name = kNames[i++ % std::size(kNames)];
      auto result = service_template::SayHelloTo(name);
      benchmark::DoNotOptimize(result);
    }
  });
}

BENCHMARK(HelloBenchmark);
