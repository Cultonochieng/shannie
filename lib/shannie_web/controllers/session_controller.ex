# lib/shannie_web/controllers/session_controller.ex
defmodule ShannieWeb.SessionController do
  use ShannieWeb, :controller

  alias Shannie.Accounts
  alias Shannie.Guardian

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> Guardian.Plug.sign_in(user)
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: Routes.dashboard_path(conn, :index))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid email/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> Guardian.Plug.sign_out()
    |> put_flash(:info, "Signed out successfully")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
