defmodule Shannie.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ShannieWeb.Telemetry,
      Shannie.Repo,
      {DNSCluster, query: Application.get_env(:shannie, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Shannie.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Shannie.Finch},
      # Start a worker by calling: Shannie.Worker.start_link(arg)
      # {Shannie.Worker, arg},
      # Start to serve requests, typically the last entry
      ShannieWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Shannie.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ShannieWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
