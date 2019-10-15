defmodule ApiGatewayWeb.Gql.Schema.NonNodeQueryPayloadTypes do
  use Absinthe.Schema.Notation

  import ApiGatewayWeb.Gql.Schema.ScalarHelperFuncs, only: [non_null_list: 1]

  object :get_media_chat_info_payload do
    field :user_can_enter_chat, non_null(:boolean)
    field :users, non_null_list(:user)
    field :active_user_ids, non_null_list(:uuid)
  end
end
