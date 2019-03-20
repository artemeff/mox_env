defmodule MoxEnv.MixProject do
  use Mix.Project

  def project do
    [
      app: :mox_env,
      version: "0.4.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp deps do
    [
      {:mox, "0.4.0"}
    ]
  end
end
