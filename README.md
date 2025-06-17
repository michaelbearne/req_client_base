# ReqClientBase

Is a macro that can be used to provided a base implementation of [Req](https://hexdocs.pm/req/readme.html) get, post, put, patch and delete http calls configured with telemetry and a circuit breaker.

## Installation

```elixir
def deps do
  [
    {:req_client_base, "~> 0.1.0"}
  ]
end
```

## Example

```elixir
defmodule Some.Http.Client do
  use ReqClientBase, service_name: :some_client

  def client_call do
    get(url: "https://some.url")
  end
end
```