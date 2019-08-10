defmodule ApiGatewayWeb.Gql.Schema.NonNodeMutationPayloadTypes do
  use Absinthe.Schema.Notation

  object :account_invitation_send_payload do
    field :ok, non_null(:boolean)
  end

  object :register_user_and_workspace_payload do
    field :user, non_null(:user)
    field :workspace, non_null(:workspace)
  end
end
