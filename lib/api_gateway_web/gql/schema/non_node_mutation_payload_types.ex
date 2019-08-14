defmodule ApiGatewayWeb.Gql.Schema.NonNodeMutationPayloadTypes do
  use Absinthe.Schema.Notation

  object :account_invitation_send_payload do
    field :ok, non_null(:boolean)
  end

  object :register_user_and_workspace_payload do
    field :user, non_null(:user)
    field :workspace, non_null(:workspace)
  end

  object :logout_user_payload do
    field :ok, non_null(:boolean)
  end

  object :send_forgot_password_email_payload do
    field :ok, non_null(:boolean)
  end

  object :send_find_my_workspaces_email_payload do
    field :ok, non_null(:boolean)
  end
end
