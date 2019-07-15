defmodule ApiGatewayWeb.Gql.Schema.BaseTypes do
  use Absinthe.Schema.Notation

  scalar :iso_date_time, description: "ISO 8601 date-time string" do
    parse(&DateTime.from_iso8601(&1.value))
    serialize(&DateTime.to_iso8601(&1))
  end

  scalar :email, description: "Email address" do
    parse(&check_email(&1))
    serialize(& &1)
  end

  interface :node do
    field :id, non_null(:id)
    field :created_at, non_null(:iso_date_time)
    field :updated_at, non_null(:iso_date_time)
  end

  object :workspace do
    interface(:node)

    field :id, non_null(:id)
    field :title, non_null(:string)
    field :workspace_domain, non_null(:string)
    field :description, :string
    field :members, :user |> list_of() |> non_null()
    field :teams, :team |> list_of() |> non_null()
    field :projects, :project |> list_of() |> non_null()
    field :storage_cap, non_null(:integer)
    field :current_storage_amount, non_null(:integer)
    field :created_at, non_null(:iso_date_time)
    field :updated_at, non_null(:iso_date_time)
  end

  ####################
  # Helper functions #
  ####################
  defp check_email(item) do
    value = item.value()
    if !is_binary(value), do: {:error, "invalid email address"}

    case Regex.match?(Utils.Regex.get_email_regex(), value) do
      true ->
        {:ok, value}

      false ->
        {:error, "invalid email address"}
    end
  end
end
