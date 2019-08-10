defmodule ApiGatewayWeb.Gql.Resolvers.AccountInvitation do
  def send_account_invitation(_, %{data: %{email: email}}, _) do
    {:ok, invitation_token} =
      ApiGateway.Models.AccountInvitation.create_or_update_account_invitation(%{email: email})

    ApiGateway.Email.Transactional.send_new_account_invitation_email(
      email,
      invitation_token
    )

    {:ok, %{ok: true}}
  end
end
