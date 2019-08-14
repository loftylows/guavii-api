defmodule ApiGatewayWeb.Gql.CommonMiddleware.Authenticated do
  @behaviour Absinthe.Middleware

  def call(resolution, _config) do
    case resolution.context do
      %{current_user: %{}} ->
        resolution

      _ ->
        Absinthe.Resolution.put_result(
          resolution,
          ApiGatewayWeb.Gql.Utils.Errors.authentication_error()
        )
    end
  end
end
