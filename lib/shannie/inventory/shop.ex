# lib/shannie/inventory/shop.ex
defmodule Shannie.Inventory.Shop do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shops" do
    field :name, :string
    field :location, :string
    field :shop_type, :string # "bale" or "retail"

    has_many :bales, Shannie.Inventory.Bale
    has_many :items, Shannie.Inventory.Item
    has_many :sales, Shannie.Sales.Sale

    timestamps()
  end

  def changeset(shop, attrs) do
    shop
    |> cast(attrs, [:name, :location, :shop_type])
    |> validate_required([:name, :shop_type])
    |> validate_inclusion(:shop_type, ["bale", "retail"])
  end
end
