# priv/repo/migrations/YYYYMMDDHHMMSS_create_items.exs
defmodule Shannie.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :name, :string
      add :description, :text
      add :category, :string
      add :size, :string
      add :purchase_price, :decimal
      add :selling_price, :decimal
      add :quantity, :integer
      add :bale_id, references(:bales), null: true
      add :shop_id, references(:shops)

      timestamps()
    end

    create index(:items, [:bale_id])
    create index(:items, [:shop_id])
  end
end
