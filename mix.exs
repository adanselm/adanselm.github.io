defmodule Adanselm.MixProject do
  use Mix.Project

  def project do
    [
      app: :adanselm,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
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
      {:tableau, "~> 0.15"},
      {:phoenix_live_view, "~> 0.20"},
      {:html_entities, "~> 0.5"},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev}
    ]
  end

  def aliases() do
    [
      build: ["tableau.build", "tailwind default --minify"],
      serve: ["tableau.server"]
    ]
  end
end
