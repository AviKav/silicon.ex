defmodule Silicon.MixProject do
  use Mix.Project


  @description """
    Elixir wrapper for Rust Silicon crate.
  """
  @version "./VERSION"
    |> File.read!()
    |> String.trim()
    |> Version.parse!()
    |> Version.to_string()
  @repo_url "https://github.com/AviKav/silicon.ex"
  @app_name :silicon

  def project do
    [
      app: @app_name,
      description: @description,
      version: @version,
      source_url: @repo_url,
      homepage_url: @repo_url,
      docs: docs(),
      package: package(),
      elixir: "~> 1.16",
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

  def docs do
    [
      name: to_string(@app_name),
      source_ref: "v#{@version}",
      extras: ~w[README.md LICENSE VERSION],
      main: "README.md",
      source_url: @repo_url,
    ]
  end

  def package do
    [
      name: @app_name,
      description: @description,
      maintainers: [],
      licenses: ["MPL-2.0"],
      files: ~w(
        lib
        native
        .formatter.exs
        mix.exs
        README*
        LICENSE*
        CHANGELOG*
        VERSION
      ),
      links: %{
        GitHub: @repo_url,
      },
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:rustler, "~> 0.30.0", runtime: false},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:type_check, "~> 0.13.3"},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
