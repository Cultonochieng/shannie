# lib/shannie/dashboard.ex
defmodule Shannie.Dashboard do
  import Ecto.Query, warn: false
  alias Shannie.Repo
  alias Shannie.Sales.Sale
  alias Shannie.Inventory.{Bale, Item}

  def get_total_sales(period \\ :all) do
    start_date = case period do
      :today -> Date.utc_today() |> DateTime.new!(~T[00:00:00], "Etc/UTC")
      :this_week -> Date.utc_today() |> Date.add(-(Date.utc_today() |> Date.day_of_week()) + 1) |> DateTime.new!(~T[00:00:00], "Etc/UTC")
      :this_month -> Date.utc_today() |> Date.beginning_of_month() |> DateTime.new!(~T[00:00:00], "Etc/UTC")
      :all -> ~N[1970-01-01 00:00:00]
    end

    Sale
    |> where([s], s.inserted_at >= ^start_date)
    |> select([s], sum(s.total_amount))
    |> Repo.one() || Decimal.new(0)
  end

  def get_sales_by_shop do
    Sale
    |> group_by([s], s.shop_id)
    |> select([s], {s.shop_id, sum(s.total_amount)})
    |> Repo.all()
    |> Enum.into(%{})
  end

  def get_inventory_summary do
    bales_query = from b in Bale,
                  where: b.status == "in_stock",
                  select: %{
                    count: count(b.id),
                    value: sum(b.purchase_price)
                  }

    items_query = from i in Item,
                  select: %{
                    count: sum(i.quantity),
                    value: sum(fragment("? * ?", i.purchase_price, i.quantity))
                  }

    %{
      bales: Repo.one(bales_query) || %{count: 0, value: Decimal.new(0)},
      items: Repo.one(items_query) || %{count: 0, value: Decimal.new(0)}
    }
  end

  def get_top_selling_items(limit \\ 5) do
    from si in "sale_items",
    left_join: i in Item, on: si.item_id == i.id,
    where: not is_nil(si.item_id),
    group_by: [i.id, i.name],
    select: %{
      id: i.id,
      name: i.name,
      total_sold: sum(si.quantity),
      total_revenue: sum(si.total_price)
    },
    order_by: [desc: sum(si.total_price)],
    limit: ^limit
  end

  def get_low_stock_items(threshold \\ 5) do
    Item
    |> where([i], i.quantity <= ^threshold and i.quantity > 0)
    |> select([i], %{
      id: i.id,
      name: i.name,
      quantity: i.quantity
    })
    |> Repo.all()
  end

  def get_out_of_stock_items do
    Item
    |> where([i], i.quantity == 0)
    |> select([i], %{
      id: i.id,
      name: i.name
    })
    |> Repo.all()
  end

  def get_sales_trend(days \\ 30) do
    start_date = Date.utc_today() |> Date.add(-days) |> DateTime.new!(~T[00:00:00], "Etc/UTC")

    Sale
    |> where([s], s.inserted_at >= ^start_date)
    |> group_by([s], fragment("date(inserted_at)"))
    |> select([s], %{
      date: fragment("date(inserted_at)"),
      total: sum(s.total_amount)
    })
    |> order_by([s], fragment("date(inserted_at)"))
    |> Repo.all()
  end
end
