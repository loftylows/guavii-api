defmodule ApiGatewayWeb.Gql.Resolvers.KanbanBoard do
  def create_kanban_board(_, %{data: data}, _) do
    case ApiGateway.Models.KanbanBoard.create_kanban_board(data) do
      {:ok, kanban_board} ->
        {:ok, kanban_board}

      {:error, %{errors: errors}} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error_from_changeset(
          "KanbanBoard input error",
          errors
        )

      {:error, _} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("KanbanBoard input error")
    end
  end

  def update_kanban_board(_, %{data: data, where: %{id: id}}, _) do
    case ApiGateway.Models.KanbanBoard.update_kanban_board(%{id: id, data: data}) do
      {:ok, kanban_board} ->
        {:ok, kanban_board}

      {:error, %{errors: errors}} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error_from_changeset(
          "KanbanBoard input error",
          errors
        )

      {:error, "Not found"} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("KanbanBoard not found")

      {:error, _} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("KanbanBoard input error")
    end
  end

  def delete_kanban_board(_, %{where: %{id: id}}, _) do
    case ApiGateway.Models.KanbanBoard.delete_kanban_board(id) do
      {:ok, kanban_board} ->
        {:ok, kanban_board}

      {:error, "Not found"} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("KanbanBoard not found")
    end
  end
end
