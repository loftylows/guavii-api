defmodule ApiGatewayWeb.Gql.Resolvers.SubListItem do
  alias ApiGateway.Models.SubListItem
  alias ApiGatewayWeb.Gql.Utils.Errors

  def get_sub_list_item(_, %{where: %{id: sub_list_item_id}}, _) do
    {:ok, SubListItem.get_sub_list_item(sub_list_item_id)}
  end

  def get_sub_list_items(_, %{where: filters}, _) do
    {:ok, SubListItem.get_sub_list_items(filters)}
  end

  def get_sub_list_items(_, _, _) do
    {:ok, SubListItem.get_sub_list_items()}
  end

  def create_sub_list_item(_, %{data: data}, _) do
    case SubListItem.create_sub_list_item(data) do
      {:ok, sub_list_item} ->
        {:ok, sub_list_item}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset(
          "SubListItem input error",
          errors
        )

      {:error, _} ->
        Errors.user_input_error("SubListItem input error")
    end
  end

  def update_sub_list_item(
        _,
        %{
          data: data,
          where: %{id: id},
          list_item_position: %{prev_item_rank: prev, next_item_rank: next}
        },
        _
      ) do
    case SubListItem.update_with_position(%{id: id, data: data, prev: prev, next: next}) do
      {:ok, sub_list_item} ->
        payload = %{
          sub_list_item: sub_list_item,
          just_normalized: false
        }

        {:ok, payload}

      # TODO: send out a subscription notification about this list normalization
      {{:list_order_normalized, _normalized_list_id, normalized_items}, {:ok, sub_list_item}} ->
        payload = %{
          sub_list_item: sub_list_item,
          just_normalized: true,
          normalized_sub_list_items: normalized_items
        }

        {:ok, payload}

      {{:list_order_normalized, _normalized_list_id, _normalized_items}, {:error, "Not found"}} ->
        Errors.user_input_error("SubListItem not found")

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset("SubListItem input error", errors)

      {:error, "Not found"} ->
        Errors.user_input_error("SubListItem not found")

      {:error, _} ->
        Errors.user_input_error("SubListItem input error")
    end
  end

  def update_sub_list_item(_, %{data: data, where: %{id: id}}, _) do
    case SubListItem.update_sub_list_item(%{id: id, data: data}) do
      {:ok, sub_list_item} ->
        payload = %{
          sub_list_item: sub_list_item,
          just_normalized: false
        }

        {:ok, payload}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset("SubListItem input error", errors)

      {:error, "Not found"} ->
        Errors.user_input_error("SubListItem not found")

      {:error, _} ->
        Errors.user_input_error("SubListItem input error")
    end
  end

  def delete_sub_list_item(_, %{where: %{id: id}}, _) do
    case SubListItem.delete_sub_list_item(id) do
      {:ok, sub_list_item} ->
        {:ok, sub_list_item}

      {:error, "Not found"} ->
        Errors.user_input_error("SubListItem not found")
    end
  end

  ####################
  # Relation resolvers #
  ####################
end
