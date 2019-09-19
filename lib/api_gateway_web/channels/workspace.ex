defmodule ApiGatewayWeb.Channels.Workspace do
  use ApiGatewayWeb, :channel
  alias ApiGatewayWeb.Presence
  alias ApiGateway.Models.Workspace
  alias ApiGateway.Models.Account.User

  def join("workspace:" <> workspace_id, _params, socket) do
    Workspace.get_workspace(workspace_id)
    |> case do
      nil ->
        {:error, %{reason: "FORBIDDEN"}}

      _workspace ->
        {:ok, _} =
          Presence.track(socket, socket.assigns.user.id, %{
            online_at: inspect(System.system_time(:second))
          })

        Absinthe.Subscription.publish(
          ApiGatewayWeb.Endpoint,
          socket.assigns.user.id,
          user_presence_joined_workspace: workspace_id
        )

        {:ok, assign(socket, :workspace_id, workspace_id)}
    end
  end

  def terminate(_reason, socket) do
    Absinthe.Subscription.publish(
      ApiGatewayWeb.Endpoint,
      socket.assigns.user.id,
      user_presence_left_workspace: socket.assigns.workspace_id
    )

    User.set_last_went_offline_now(socket.assigns.user.id)

    :ok
  end
end
