# lib/shannie_web/controllers/dashboard_controller.ex
defmodule ShannieWeb.DashboardController do
  use ShannieWeb, :controller
  alias Shannie.Dashboard
  alias Shannie.Guardian

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    dashboard_data = %{
      total_sales_today: Dashboard.get_total_sales(:today),
      total_sales_week: Dashboard.get_total_sales(:this_week),
      total_sales_month: Dashboard.get_total_sales(:this_month),
      inventory_summary: Dashboard.get_inventory_summary(),
      sales_by_shop: Dashboard.get_sales_by_shop(),
      top_selling_items: Dashboard.get_top_selling_items(),
      low_stock_items: Dashboard.get_low_stock_items(),
      out_of_stock_items: Dashboard.get_out_of_stock_items(),
      sales_trend: Dashboard.get_sales_trend()
    }

    render(conn, "index.html", data: dashboard_data, user: user)
  end
end
