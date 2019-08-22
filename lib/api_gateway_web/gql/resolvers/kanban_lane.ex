defmodule ApiGatewayWeb.Gql.Resolvers.KanbanLane do
  alias ApiGateway.Models.KanbanLane
  alias ApiGatewayWeb.Gql.Utils.Errors

  def get_kanban_lane(_, %{where: %{id: kanban_lane_id}}, _) do
    {:ok, KanbanLane.get_kanban_lane(kanban_lane_id)}
  end

  def get_kanban_lanes(_, %{where: filters}, _) do
    {:ok, KanbanLane.get_kanban_lanes(filters)}
  end

  def get_kanban_lanes(_, _, _) do
    {:ok, KanbanLane.get_kanban_lanes()}
  end

  def create_kanban_lane(_, %{data: data}, _) do
    case KanbanLane.create_kanban_lane(data) do
      {:ok, kanban_lane} ->
        {:ok, kanban_lane}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset(
          "KanbanLane input error",
          errors
        )

      {:error, _} ->
        Errors.user_input_error("KanbanLane input error")
    end
  end

  def update_kanban_lane(
        _,
        %{
          data: data,
          where: %{id: id},
          list_item_position: %{prev_item_rank: prev, next_item_rank: next}
        },
        _
      ) do
    case KanbanLane.update_with_position(%{id: id, data: data, prev: prev, next: next}) do
      {:ok, kanban_lane} ->
        payload = %{
          kanban_lane: kanban_lane,
          just_normalized: false
        }

        {:ok, payload}

      # TODO: send out a subscription notification about this list normalization
      {{:list_order_normalized, _normalized_list_id, normalized_items}, {:ok, kanban_lane}} ->
        payload = %{
          kanban_lane: kanban_lane,
          just_normalized: true,
          normalized_kanban_lanes: normalized_items
        }

        {:ok, payload}

      {{:list_order_normalized, _normalized_list_id, _normalized_items}, {:error, "Not found"}} ->
        Errors.user_input_error("KanbanLane not found")

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset("KanbanLane input error", errors)

      {:error, "Not found"} ->
        Errors.user_input_error("KanbanLane not found")

      {:error, _} ->
        Errors.user_input_error("KanbanLane input error")
    end
  end

  def update_kanban_lane(_, %{data: data, where: %{id: id}}, _) do
    case KanbanLane.update_kanban_lane(%{id: id, data: data}) do
      {:ok, kanban_lane} ->
        payload = %{
          kanban_lane: kanban_lane,
          just_normalized: false
        }

        {:ok, payload}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset("KanbanLane input error", errors)

      {:error, "Not found"} ->
        Errors.user_input_error("KanbanLane not found")

      {:error, _} ->
        Errors.user_input_error("KanbanLane input error")
    end
  end

  def delete_kanban_lane(_, %{where: %{id: id}}, _) do
    case KanbanLane.delete_kanban_lane(id) do
      {:ok, kanban_lane} ->
        {:ok, kanban_lane}

      {:error, "Not found"} ->
        Errors.user_input_error("KanbanLane not found")
    end
  end

  ####################
  # Relation resolvers #
  ####################
end
