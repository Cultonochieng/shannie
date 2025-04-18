# lib/shannie/sales.ex
defmodule Shannie.Sales do
  import Ecto.Query, warn: false
  alias Shannie.Repo
  alias Shannie.Sales.{Sale, SaleItem}
  alias Shannie.Inventory

  def list_sales do
    Repo.all(Sale)
    |> Repo.preload([:user, :shop, :sale_items])
  end

  def list_shop_sales(shop_id) do
    Sale
    |> where([s], s.shop_id == ^shop_id)
    |> Repo.all()
    |> Repo.preload([:user, :shop, :sale_items])
  end

  def get_sale!(id) do
    Repo.get!(Sale, id)
    |> Repo.preload([:user, :shop, sale_items: [:item, :bale]])
  end

  def create_sale(attrs \\ %{}) do
    Repo.transaction(fn ->
      # Create the sale record
      %Sale{}
      |> Sale.changeset(attrs)
      |> Repo.insert()
      |> case do
        {:ok, sale} ->
          # Process each sale item
          sale_items = Map.get(attrs, "sale_items", [])
          process_sale_items(sale, sale_items)

          # Reload the sale with all associations
          get_sale!(sale.id)

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  defp process_sale_items(sale, sale_items) do
    Enum.each(sale_items, fn item_attrs ->
      # Create the sale item
      sale_item_attrs = Map.put(item_attrs, "sale_id", sale.id)
      {:ok, sale_item} = create_sale_item(sale_item_attrs)

      # Update inventory
      if sale_item.item_id do
        item = Inventory.get_item!(sale_item.item_id)
        Inventory.adjust_item_quantity(item, -sale_item.quantity)
      else
        bale = Inventory.get_bale!(sale_item.bale_id)
        Inventory.update_bale(bale, %{status: "sold"})
      end
    end)
  end

  def update_sale(%Sale{} = sale, attrs) do
    sale
    |> Sale.changeset(attrs)
    |> Repo.update()
  end

  def delete_sale(%Sale{} = sale) do
    Repo.delete(sale)
  end

  def create_sale_item(attrs \\ %{}) do
    %SaleItem{}
    |> SaleItem.changeset(attrs)
    |> Repo.insert()
  end

  def get_sales_by_period(start_date, end_date) do
    Sale
    |> where([s], s.inserted_at >= ^start_date and s.inserted_at <= ^end_date)
    |> Repo.all()
    |> Repo.preload([:user, :shop, :sale_items])
  end

  def get_sales_by_shop_and_period(shop_id, start_date, end_date) do
    Sale
    |> where([s], s.shop_id == ^shop_id and s.inserted_at >= ^start_date and s.inserted_at <= ^end_date)
    |> Repo.all()
    |> Repo.preload([:user, :shop, :sale_items])
  end

  def generate_invoice_number do
    date_part = Date.utc_today() |> Date.to_string() |> String.replace("-", "")
    random_part = :crypto.strong_rand_bytes(3) |> Base.encode16()
    "INV-#{date_part}-#{random_part}"
  end
end
