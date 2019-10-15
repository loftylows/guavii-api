defmodule ApiGatewayWeb.Gql.Schema.NonNodeSubscriptionPayloadTypes do
  use Absinthe.Schema.Notation

  object :user_presence_joined_document_payload do
    field :user, non_null(:user)
    field :document, non_null(:document)
  end

  object :user_presence_left_document_payload do
    field :user, :user
    field :document, non_null(:document)
  end

  object :media_chat_call_received_payload do
    field :chat_id, non_null(:uuid)
    field :invited_by, non_null(:user)
  end
end
