# lib/shannie/sales/sale.ex
defmodule Shannie.Sales.Sale do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sales" do
    field :invoice_number, :string
    field :total_amount, :decimal
    field :payment_method, :string

    belongs_to :user, Shannie.Accounts.User
    belongs_to :shop, Shannie.Inventory.Shop
    has_many :sale_items, Shannie.Sales.SaleItem, on_replace: :delete

    timestamps()
  end

  def changeset(sale, attrs) do
    sale
    |> cast(attrs, [:invoice_number, :total_amount, :payment_method, :user_id, :shop_id])
    |> cast_assoc(:sale_items)
    |> validate_required([:invoice_number, :total_amount, :payment_method, :user_id, :shop_id])
    |> unique_constraint(:invoice_number)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:shop_id)
  end
end
