defmodule ApiGatewayWeb.Gql.Schema.NonNodeQueryPayloadTypes do
  use Absinthe.Schema.Notation

  import ApiGatewayWeb.Gql.Schema.ScalarHelperFuncs, only: [non_null_list: 1]

  object :get_media_chat_info_payload do
    field :caller, non_null(:user)
    field :recipient, non_null(:user)
    field :invitees, non_null_list(:user)
    field :active_user_ids, non_null_list(:uuid)
  end
end
