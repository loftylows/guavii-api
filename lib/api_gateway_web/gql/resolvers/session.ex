defmodule ApiGatewayWeb.Gql.Resolvers.Session do
  @spec verify_token(any, %{data: %{token: nil | binary}}, any) ::
          {:error, :expired | :invalid | :missing} | {:ok, any}
  def verify_token(
        _,
        %{
          data: %{
            token: token
          }
        },
        _
      ) do
    ApiGatewayWeb.Session.verify_token(token)
    |> case do
      {:error, _} ->
        {:ok, false}

      {:ok, _} ->
        {:ok, true}
    end
  end
end
