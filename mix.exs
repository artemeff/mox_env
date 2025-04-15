defmodule MoxEnv.MixProject do
  use Mix.Project

  def project do
    [
      app: :mox_env,
      version: "1.1.0",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # package
      description: description(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {MoxEnv.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:nimble_ownership, "~> 1.0"},
      {:ex_doc, "~> 0.37", only: :dev}
    ]
  end

  defp description do
    "It's your application config but simply mocked with NimbleOwnership like Mox"
  end

  defp package do
    [
      links: %{"GitHub" => "https://github.com/artemeff/mox_env"},
      licenses: ["MIT"]
    ]
  end
end
