defmodule ReqClientBase.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/michaelbearne/req_client_base"

  def project do
    [
      app: :req_client_base,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      docs: docs(),
      deps: deps(),
      package: package(),
      description: description()
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
      {:opentelemetry_req, "~> 1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Utility base macro for building HTTP clients with Req."
  end

  # https://hexdocs.pm/hex/Mix.Tasks.Hex.Build.html#module-package-configuration
  defp package do
    [
      name: "req_client_base",
      maintainers: ["Michael Bearne"],
      links: %{"GitHub" => @source_url},
      licenses: ["MIT"]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end
