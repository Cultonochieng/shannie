# lib/shannie/inventory/item.ex
defmodule Shannie.Inventory.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :name, :string
    field :description, :text
    field :category, :string
    field :size, :string
    field :purchase_price, :decimal
    field :selling_price, :decimal
    field :quantity, :integer

    belongs_to :bale, Shannie.Inventory.Bale, on_replace: :nilify
    belongs_to :shop, Shannie.Inventory.Shop
    has_many :sale_items, Shannie.Sales.SaleItem

    timestamps()
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :description, :category, :size, :purchase_price, :selling_price, :quantity, :bale_id, :shop_id])
    |> validate_required([:name, :category, :selling_price, :quantity, :shop_id])
    |> foreign_key_constraint(:bale_id)
    |> foreign_key_constraint(:shop_id)
  end
end
