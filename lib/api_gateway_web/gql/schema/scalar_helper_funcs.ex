defmodule ApiGatewayWeb.Gql.Schema.ScalarHelperFuncs do
  @spec check_email(Absinthe.Blueprint.Input.String.t()) ::
          {:ok, String.t()} | {:error, String.t()}
  def check_email(%Absinthe.Blueprint.Input.String{value: value}) do
    case Regex.match?(Utils.Regex.get_email_regex(), value) do
      true ->
        {:ok, value}

      false ->
        {:error, "invalid email address"}
    end
  end

  def check_email(_), do: {:error, "invalid email address"}
end
