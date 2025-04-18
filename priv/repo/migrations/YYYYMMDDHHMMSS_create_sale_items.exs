# priv/repo/migrations/YYYYMMDDHHMMSS_create_sale_items.exs
defmodule Shannie.Repo.Migrations.CreateSaleItems do
  use Ecto.Migration

  def change do
    create table(:sale_items) do
      add :quantity, :integer
      add :unit_price, :decimal
      add :total_price, :decimal
      add :sale_id, references(:sales)
      add :item_id, references(:items), null: true
      add :bale_id, references(:bales), null: true

      timestamps()
    end

    create index(:sale_items, [:sale_id])
    create index(:sale_items, [:item_id])
    create index(:sale_items, [:bale_id])
  end
end
