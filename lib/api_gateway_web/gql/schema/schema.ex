defmodule ApiGatewayWeb.Gql.Schema.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  import_types(ApiGatewayWeb.Gql.Schema.BaseTypes)

  # Example data
  @items %{
    "foo" => %{id: "foo", name: "Foo"},
    "bar" => %{id: "bar", name: "Bar"}
  }

  @desc "An item"
  object :item do
    field :id, :id
    field :name, :string
  end

  query do
    field :item, :item do
      arg(:id, non_null(:id))

      resolve(fn %{id: item_id}, _ ->
        {:ok, @items[item_id]}
      end)
    end
  end
end
