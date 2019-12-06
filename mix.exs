defmodule MoxEnv.MixProject do
  use Mix.Project

  def project do
    [
      app: :mox_env,
      version: "0.5.2",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # package
      description: description(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp deps do
    [
      {:mox, "~> 0.5.1"},
      {:ex_doc, "~> 0.19", only: :dev},
    ]
  end

  defp description do
    "It's your application config but simply mocked with Mox."
  end

  defp package do
    [
      links: %{"GitHub" => "https://github.com/artemeff/mox_env"},
      licenses: ["MIT"]
    ]
  end
end
