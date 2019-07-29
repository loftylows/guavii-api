defmodule ApiGatewayWeb.Gql.Resolvers.SubList do
  alias ApiGateway.Models.SubList
  alias ApiGatewayWeb.Gql.Utils.Errors

  def get_sub_list(_, %{where: %{id: sub_list_id}}, _) do
    {:ok, SubList.get_sub_list(sub_list_id)}
  end

  def get_sub_lists(_, %{where: filters}, _) do
    {:ok, SubList.get_sub_lists(filters)}
  end

  def get_sub_lists(_, _, _) do
    {:ok, SubList.get_sub_lists()}
  end

  def create_sub_list(_, %{data: data}, _) do
    case SubList.create_sub_list(data) do
      {:ok, sub_list} ->
        {:ok, sub_list}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset(
          "SubList input error",
          errors
        )

      {:error, _} ->
        Errors.user_input_error("SubList input error")
    end
  end

  def update_sub_list(
        _,
        %{
          data: data,
          where: %{id: id},
          list_item_position: %{prev_item_rank: prev, next_item_rank: next}
        },
        _
      ) do
    case SubList.update_with_position(%{id: id, data: data, prev: prev, next: next}) do
      # TODO: send out a subscription notification about this list normalization
      {{:list_order_normalized, _normalized_list_id}, {:ok, sub_list}} ->
        {:ok, sub_list}

      {{:list_order_normalized, _normalized_list_id}, {:error, "Not found"}} ->
        Errors.user_input_error("SubList not found")

      {:ok, sub_list} ->
        {:ok, sub_list}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset("SubList input error", errors)

      {:error, "Not found"} ->
        Errors.user_input_error("SubList not found")

      {:error, _} ->
        Errors.user_input_error("SubList input error")
    end
  end

  def update_sub_list(_, %{data: data, where: %{id: id}}, _) do
    case SubList.update_sub_list(%{id: id, data: data}) do
      {:ok, sub_list} ->
        {:ok, sub_list}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset("SubList input error", errors)

      {:error, "Not found"} ->
        Errors.user_input_error("SubList not found")

      {:error, _} ->
        Errors.user_input_error("SubList input error")
    end
  end

  def delete_sub_list(_, %{where: %{id: id}}, _) do
    case SubList.delete_sub_list(id) do
      {:ok, sub_list} ->
        {:ok, sub_list}

      {:error, "Not found"} ->
        Errors.user_input_error("SubList not found")
    end
  end

  ####################
  # Relation resolvers #
  ####################
end
