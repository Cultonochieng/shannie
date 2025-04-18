# lib/shannie_web/plugs/auth_error_handler.ex
defmodule ShannieWeb.AuthErrorHandler do
  import Phoenix.Controller
  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_flash(:error, "Authentication required: #{to_string(type)}")
    |> redirect(to: ShannieWeb.Router.Helpers.session_path(conn, :new))
  end
end
