# priv/repo/migrations/YYYYMMDDHHMMSS_create_bales.exs
defmodule Shannie.Repo.Migrations.CreateBales do
  use Ecto.Migration

  def change do
    create table(:bales) do
      add :reference_number, :string
      add :category, :string
      add :purchase_price, :decimal
      add :selling_price, :decimal
      add :status, :string, default: "in_stock" # in_stock, sold, opened
      add :shop_id, references(:shops)

      timestamps()
    end

    create index(:bales, [:shop_id])
    create unique_index(:bales, [:reference_number])
  end
end
