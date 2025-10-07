defmodule ConcreteOptics.MixProject do
  use Mix.Project

  @source_url "https://github.com/beatrichartz/csv"

  def project do
    [
      app: :concrete_optics,
      description: "Simple minded optics implementation",
      version: "0.1.0",
      elixir: "~> 1.15",
      deps: deps(),
      package: package(),
      elixirc_paths: elixirc_paths(),
      description: "Simple minded optics implementation",
      default_env: :dev,

      #Document related
      name: "ConcreteOptics",
      source_url: "",
      homepage_url: "",
      docs: &docs/0,
    ]
  end

  defp package do
    [
      maintainers: ["Sonat Süer"],
      licenses: ["MIT"],
      links: %{GitHub: @source_url},
      files: ~w(lib mix.exs README.md LICENSE)
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.38", only: :dev, runtime: false, warn_if_outdated: true}
    ]
  end

  defp elixirc_paths do
    if Mix.env() == :test || Mix.env() == :dev do
      ["lib", "test"]
    else
      ["lib"]
    end
  end

  defp docs do
    [
      main: "ConcreteOptics",
      api_reference: false,
      extras:
        ["doc-extras/intro.md": [title: "Introduction"],
         "doc-extras/showcase.md": [title: "Showcase"],
        ]
    ]
  end
end
