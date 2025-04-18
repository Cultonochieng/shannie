# lib/shannie_web/router.ex
defmodule ShannieWeb.Router do
  use ShannieWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ShannieWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug ShannieWeb.AuthPipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :admin_only do
    plug ShannieWeb.EnsureRole, ["admin"]
  end

  pipeline :admin_or_manager do
    plug ShannieWeb.EnsureRole, ["admin", "manager"]
  end

  # Public routes
  scope "/", ShannieWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/about", PageController, :about
    get "/contact", PageController, :contact

    get "/login", SessionController, :new
    post "/login", SessionController, :create
    delete "/logout", SessionController, :delete
  end

  # Authenticated routes
  scope "/app", ShannieWeb do
    pipe_through [:browser, :auth, :ensure_auth]

    get "/dashboard", DashboardController, :index

    resources "/sales", SaleController

    resources "/items", ItemController do
      get "/adjust_quantity", ItemController, :adjust_quantity_form, as: :adjust
      post "/adjust_quantity", ItemController, :adjust_quantity, as: :adjust
    end

    resources "/bales", BaleController do
      get "/open", BaleController, :open_form, as: :open
      post "/open", BaleController, :open, as: :open
    end

    get "/reports", ReportController, :index
    get "/reports/sales", ReportController, :sales
    get "/reports/inventory", ReportController, :inventory
    get "/reports/profit", ReportController, :profit
  end

  # Admin only routes
  scope "/admin", ShannieWeb.Admin, as: :admin do
    pipe_through [:browser, :auth, :ensure_auth, :admin_only]

    resources "/users", UserController
    resources "/shops", ShopController

    get "/settings", SettingController, :index
    put "/settings", SettingController, :update
  end

  # Enables LiveDashboard only for development
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: ShannieWeb.Telemetry
    end
  end
end
