# lib/shannie/inventory/bale.ex
defmodule Shannie.Inventory.Bale do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bales" do
    field :reference_number, :string
    field :category, :string
    field :purchase_price, :decimal
    field :selling_price, :decimal
    field :status, :string, default: "in_stock" # in_stock, sold, opened

    belongs_to :shop, Shannie.Inventory.Shop
    has_many :items, Shannie.Inventory.Item
    has_many :sale_items, Shannie.Sales.SaleItem

    timestamps()
  end

  def changeset(bale, attrs) do
    bale
    |> cast(attrs, [:reference_number, :category, :purchase_price, :selling_price, :status, :shop_id])
    |> validate_required([:reference_number, :category, :purchase_price, :shop_id])
    |> validate_inclusion(:status, ["in_stock", "sold", "opened"])
    |> unique_constraint(:reference_number)
    |> foreign_key_constraint(:shop_id)
  end
end
