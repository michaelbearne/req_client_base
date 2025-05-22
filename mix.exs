defmodule ReqClientBase.MixProject do
  use Mix.Project

  def project do
    [
      app: :req_client_base,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5"},
      {:req_fuse, "~> 0.3"},
      {:req_telemetry, "~> 0.1"},
      {:opentelemetry_req, "~> 1.0"}
    ]
  end
end
