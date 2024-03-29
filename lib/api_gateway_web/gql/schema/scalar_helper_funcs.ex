defmodule ApiGatewayWeb.Gql.Schema.ScalarHelperFuncs do
  use Absinthe.Schema.Notation

  @doc "Check email is valid for 'Email' GraphQL type"
  @spec check_email(Absinthe.Blueprint.Input.String.t()) ::
          {:ok, String.t()} | {:error, String.t()}
  def check_email(%Absinthe.Blueprint.Input.String{value: value}) do
    case Regex.match?(Utils.Regex.get_email_regex(), value) do
      true ->
        {:ok, value}

      false ->
        :error
    end
  end

  def check_email(_), do: :error

  @doc "Non null list of the type provided with non null values"
  def non_null_list(term, options \\ [non_null_members: true])

  def non_null_list(term, non_null_members: true) when is_atom(term) do
    term |> non_null() |> list_of |> non_null()
  end

  def non_null_list(term, _) when is_atom(term) do
    term |> list_of |> non_null()
  end
end
