defmodule ApiGatewayWeb.Gql.Schema.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  import_types(ApiGatewayWeb.Gql.Schema.BaseTypes)
  import_types(ApiGatewayWeb.Gql.Schema.QueryType)

  @desc "Root query type"
  query do
    import_fields(:root_queries)
  end
end
