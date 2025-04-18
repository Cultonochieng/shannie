defmodule Shannie.Repo do
  use Ecto.Repo,
    otp_app: :shannie,
    adapter: Ecto.Adapters.Postgres
end
