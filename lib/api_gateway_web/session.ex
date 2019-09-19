defmodule ApiGatewayWeb.Session do
  @salt "YSJQnKt6uXn66lGPOf6uhczvlU5hykOLRoP9uRQBG3hAyDiUNqtpkXcILGLPVKLxsaltysalt"

  @spec create_token(String.t()) :: String.t()
  def create_token(user_id) do
    Phoenix.Token.sign(ApiGatewayWeb.Endpoint, @salt, user_id)
  end

  def verify_token(token) do
    Phoenix.Token.verify(ApiGatewayWeb.Endpoint, @salt, token, max_age: 604_800)
  end
end
