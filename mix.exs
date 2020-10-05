defmodule StandupBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :standup_bot,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp escript do
    [main_module: StandupBot.CLI]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:slack, "~> 0.23.5"},
      {:poison, "~> 3.1"},
      {:tentacat, "~> 2.0"}
    ]
  end
end
