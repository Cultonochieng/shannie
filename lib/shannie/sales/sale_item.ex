# lib/shannie/sales/sale_item.ex
defmodule Shannie.Sales.SaleItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sale_items" do
    field :quantity, :integer
    field :unit_price, :decimal
    field :total_price, :decimal

    belongs_to :sale, Shannie.Sales.Sale
    belongs_to :item, Shannie.Inventory.Item
    belongs_to :bale, Shannie.Inventory.Bale

    timestamps()
  end

  def changeset(sale_item, attrs) do
    sale_item
    |> cast(attrs, [:quantity, :unit_price, :total_price, :sale_id, :item_id, :bale_id])
    |> validate_required([:quantity, :unit_price, :total_price, :sale_id])
    |> validate_number(:quantity, greater_than: 0)
    |> check_item_or_bale()
    |> foreign_key_constraint(:sale_id)
    |> foreign_key_constraint(:item_id)
    |> foreign_key_constraint(:bale_id)
  end

  defp check_item_or_bale(changeset) do
    item_id = get_field(changeset, :item_id)
    bale_id = get_field(changeset, :bale_id)

    cond do
      is_nil(item_id) and is_nil(bale_id) ->
        add_error(changeset, :base, "Either item or bale must be specified")
      not is_nil(item_id) and not is_nil(bale_id) ->
        add_error(changeset, :base, "Cannot specify both item and bale")
      true ->
        changeset
    end
  end
end
