defmodule ApiGatewayWeb.Channels.Workspace do
  use ApiGatewayWeb, :channel
  alias ApiGatewayWeb.Presence
  alias ApiGateway.Models.Workspace

  def join("workspace:" <> workspace_id, _params, socket) do
    ApiGateway.Models.Workspace.get_workspace(workspace_id)
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

  def handle_info(:after_join, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.user.id, %{
        online_at: inspect(System.system_time(:second))
      })

    Absinthe.Subscription.publish(
      ApiGatewayWeb.Endpoint,
      socket.assigns.user.id,
      user_presence_joined_workspace: socket.assigns.workspace_id
    )

    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    Absinthe.Subscription.publish(
      ApiGatewayWeb.Endpoint,
      socket.assigns.user.id,
      user_presence_left_workspace: socket.assigns.workspace_id
    )

    :ok
  end
end
