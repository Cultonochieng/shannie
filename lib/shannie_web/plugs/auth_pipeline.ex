# lib/shannie_web/plugs/auth_pipeline.ex
defmodule ShannieWeb.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :shannie,
    error_handler: ShannieWeb.AuthErrorHandler,
    module: Shannie.Guardian

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  plug Guardian.Plug.LoadResource, allow_blank: true
end
