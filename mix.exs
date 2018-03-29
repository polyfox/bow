defmodule Bow.Mixfile do
  use Mix.Project

  def project do
    [
      app: :bow,
      version: "0.1.0",
      elixir: "~> 1.3",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: Coverex.Task]
    ]
  end

  def application do
    [
      applications: [:logger, :plug, :tesla] ++ applications(Mix.env)
    ]

    # TODO: Uncomment wneh dropping support for elixir 1.3
    # [
    #   extra_applications: [:logger] ++ applications(Mix.env)
    # ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp applications(:test) do
    [
      :ecto, :postgrex,     # Bow.Ecto
      :erlexec,             # Bow.Exec
      :hackney, :sweet_xml  # Bow.Storage.S3
    ]
  end
  defp applications(_), do: []

  defp deps do
    [
      {:plug,     "~> 1.0"},
      {:tesla,    "~> 0.7"},

      {:ecto,       "~> 2.2", optional: true},
      {:erlexec,    "~> 1.7", optional: true},
      {:ex_aws,     "~> 1.1", optional: true},
      {:sweet_xml,  "~> 0.6", optional: true},

      # testing & docs
      {:postgrex,       ">= 0.0.0",only: :test},
      {:coverex,        "~> 1.4",  only: :test},
      {:ex_doc,         "~> 0.16", only: :dev},
      {:mix_test_watch, "~> 0.5",  only: :dev},
      {:dialyxir,       "~> 0.5",  only: :dev}
    ]
  end

  def aliases do
    ["ecto.setup": ["ecto.create --quiet", "ecto.migrate --quiet"],
     "ecto.reset": ["ecto.drop --quiet", "ecto.setup"]]
  end
end
