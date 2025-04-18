# lib/shannie/inventory.ex
defmodule Shannie.Inventory do
  import Ecto.Query, warn: false
  alias Shannie.Repo
  alias Shannie.Inventory.{Shop, Bale, Item}

  # Shop functions
  def list_shops do
    Repo.all(Shop)
  end

  def get_shop!(id), do: Repo.get!(Shop, id)

  def create_shop(attrs \\ %{}) do
    %Shop{}
    |> Shop.changeset(attrs)
    |> Repo.insert()
  end

  def update_shop(%Shop{} = shop, attrs) do
    shop
    |> Shop.changeset(attrs)
    |> Repo.update()
  end

  def delete_shop(%Shop{} = shop) do
    Repo.delete(shop)
  end

  # Bale functions
  def list_bales do
    Repo.all(Bale)
  end

  def list_shop_bales(shop_id) do
    Bale
    |> where([b], b.shop_id == ^shop_id)
    |> Repo.all()
  end

  def get_bale!(id), do: Repo.get!(Bale, id)

  def create_bale(attrs \\ %{}) do
    %Bale{}
    |> Bale.changeset(attrs)
    |> Repo.insert()
  end

  def update_bale(%Bale{} = bale, attrs) do
    bale
    |> Bale.changeset(attrs)
    |> Repo.update()
  end

  def delete_bale(%Bale{} = bale) do
    Repo.delete(bale)
  end

  def open_bale(%Bale{} = bale) do
    update_bale(bale, %{status: "opened"})
  end

  # Item functions
  def list_items do
    Repo.all(Item)
  end

  def list_shop_items(shop_id) do
    Item
    |> where([i], i.shop_id == ^shop_id)
    |> Repo.all()
  end

  def list_bale_items(bale_id) do
    Item
    |> where([i], i.bale_id == ^bale_id)
    |> Repo.all()
  end

  def get_item!(id), do: Repo.get!(Item, id)

  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  def create_items_from_bale(%Bale{} = bale, items_attrs) do
    Repo.transaction(fn ->
      # Mark bale as opened
      {:ok, updated_bale} = open_bale(bale)

      # Create all items
      results = Enum.map(items_attrs, fn attrs ->
        attrs = Map.merge(attrs, %{
          bale_id: bale.id,
          shop_id: bale.shop_id
        })

        create_item(attrs)
      end)

      # Check if all items were created successfully
      if Enum.all?(results, fn {status, _} -> status == :ok end) do
        {updated_bale, Enum.map(results, fn {:ok, item} -> item end)}
      else
        Repo.rollback(:items_creation_failed)
      end
    end)
  end

  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  def adjust_item_quantity(%Item{} = item, by) do
    new_quantity = item.quantity + by

    if new_quantity >= 0 do
      update_item(item, %{quantity: new_quantity})
    else
      {:error, :insufficient_quantity}
    end
  end
end
