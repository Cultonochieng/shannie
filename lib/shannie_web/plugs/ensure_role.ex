# lib/shannie_web/plugs/ensure_role.ex
defmodule ShannieWeb.EnsureRole do
  import Plug.Conn
  import Phoenix.Controller

  alias Shannie.Guardian
  alias ShannieWeb.Router.Helpers, as: Routes

  def init(options), do: options

  def call(conn, roles) do
    user = Guardian.Plug.current_resource(conn)

    if user && Enum.member?(roles, user.role) do
      conn
    else
      conn
      |> put_flash(:error, "You don't have access to that page")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end
end
