# priv/repo/migrations/YYYYMMDDHHMMSS_create_shops.exs
defmodule Shannie.Repo.Migrations.CreateShops do
  use Ecto.Migration

  def change do
    create table(:shops) do
      add :name, :string
      add :location, :string
      add :shop_type, :string # "bale" or "retail"

      timestamps()
    end
  end
end
