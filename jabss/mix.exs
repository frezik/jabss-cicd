defmodule Jabss.MixProject do
  use Mix.Project

  def project do
    [
      app: :jabss,
      description: description(),
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps()
    ]
  end

  defp description do
    """
    Just A Bunch of Shell Scripts CI/CD
    """
  end

  defp package do
    [
      licenses: ["BSD-2-Clause"],
      maintainers: ["Timm Murray"],
      links: %{
        "GitHub" => "https://github.com/frezik/jabss-cicd"
      },
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
      {:yaml_elixir, "~> 2.9.0"},
      {:ymlr, "~> 5.1.3"}
    ]
  end
end
