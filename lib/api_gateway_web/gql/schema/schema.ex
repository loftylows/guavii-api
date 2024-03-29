defmodule ApiGatewayWeb.Gql.Schema.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  import_types(ApiGatewayWeb.Gql.Schema.BaseTypes)
  import_types(ApiGatewayWeb.Gql.Schema.CommonInputTypes)
  import_types(ApiGatewayWeb.Gql.Schema.QueryInputTypes)
  import_types(ApiGatewayWeb.Gql.Schema.NonNodeQueryPayloadTypes)
  import_types(ApiGatewayWeb.Gql.Schema.QueryType)
  import_types(ApiGatewayWeb.Gql.Schema.MutationInputTypes)
  import_types(ApiGatewayWeb.Gql.Schema.NonNodeMutationPayloadTypes)
  import_types(ApiGatewayWeb.Gql.Schema.MutationType)
  import_types(ApiGatewayWeb.Gql.Schema.SubscriptionInputTypes)
  import_types(ApiGatewayWeb.Gql.Schema.NonNodeSubscriptionPayloadTypes)
  import_types(ApiGatewayWeb.Gql.Schema.SubscriptionType)

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(ApiGateway.Dataloader, ApiGateway.Dataloader.data())

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end

  @desc "Root query type"
  query do
    import_fields(:root_queries)
  end

  @desc "Root mutation type"
  mutation do
    import_fields(:root_mutations)
  end

  @desc "Root subscription type"
  subscription do
    import_fields(:root_subscriptions)
  end
end
