defmodule XMax.Mixfile do
  use Mix.Project

  @version "1.0.0"

  def project do
    [
      app: :xmax,
      name: "XMax",
      version: @version,
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      deps: deps(),
      package: package(),
      preferred_cli_env: [docs: :docs],
      description: description(),
      docs: docs(),
      test_coverage: [tool: XMax.Cover]
    ]
  end

  def application do
    [
      extra_applications: [:xmerl]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:credo, "~> 0.8.10", only: :dev},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    """
    XML to Map converter.
    """
  end

  defp package do
    [
      maintainers: ["Attila Gal"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/AttilaGal/xmax"},
      files: ~w(mix.exs LICENSE README.md lib)
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "XMax",
      canonical: "http://hexdocs.pm/xmax",
      source_url: "https://github.com/AttilaGal/xmax"
    ]
  end
end
