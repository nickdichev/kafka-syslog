defmodule KafkaSyslog.MixProject do
  use Mix.Project

  def project do
    [
      app: :kafka_syslog,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {KafkaSyslog.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nsyslog, git: "https://github.com/nickdichev/nsyslog.git", tag: "0.1.4"},
      {:kafka_ex, "~> 0.10.0"},
      {:jason, "~> 1.1"}
    ]
  end
end
