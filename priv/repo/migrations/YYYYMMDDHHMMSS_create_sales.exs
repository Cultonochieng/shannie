# priv/repo/migrations/YYYYMMDDHHMMSS_create_sales.exs
defmodule Shannie.Repo.Migrations.CreateSales do
  use Ecto.Migration

  def change do
    create table(:sales) do
      add :invoice_number, :string
      add :total_amount, :decimal
      add :payment_method, :string
      add :user_id, references(:users)
      add :shop_id, references(:shops)

      timestamps()
    end

    create index(:sales, [:user_id])
    create index(:sales, [:shop_id])
    create unique_index(:sales, [:invoice_number])
  end
end
