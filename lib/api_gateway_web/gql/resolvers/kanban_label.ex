defmodule ApiGatewayWeb.Gql.Resolvers.KanbanLabel do
  alias ApiGatewayWeb.Gql.Utils.Errors
  alias ApiGateway.Models

  def get_kanban_label(_, %{where: %{id: kanban_label_id}}, _) do
    {:ok, Models.KanbanLabel.get_kanban_label(kanban_label_id)}
  end

  def get_kanban_labels(_, %{where: filters}, _) do
    {:ok, Models.KanbanLabel.get_kanban_labels(filters)}
  end

  def get_kanban_labels(_, _, _) do
    {:ok, Models.KanbanLabel.get_kanban_labels()}
  end

  def create_kanban_label(_, %{data: data}, _) do
    case Models.KanbanLabel.create_kanban_label(data) do
      {:ok, kanban_label} ->
        {:ok, kanban_label}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset(
          "KanbanLabel input error",
          errors
        )

      {:error, _} ->
        Errors.user_input_error("KanbanLabel input error")
    end
  end

  def update_kanban_label(_, %{data: data, where: %{id: id}}, _) do
    case Models.KanbanLabel.update_kanban_label(%{id: id, data: data}) do
      {:ok, kanban_label} ->
        {:ok, kanban_label}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset(
          "KanbanLabel input error",
          errors
        )

      {:error, "Not found"} ->
        Errors.user_input_error("KanbanLabel not found")

      {:error, _} ->
        Errors.user_input_error("KanbanLabel input error")
    end
  end

  def delete_kanban_label(_, %{where: %{id: id}}, _) do
    case Models.KanbanLabel.delete_kanban_label(id) do
      {:ok, kanban_label} ->
        {:ok, kanban_label}

      {:error, "Not found"} ->
        Errors.user_input_error("KanbanLabel not found")
    end
  end

  ####################
  # Relation resolvers #
  ####################
end
