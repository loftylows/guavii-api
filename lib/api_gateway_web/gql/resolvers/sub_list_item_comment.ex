defmodule ApiGatewayWeb.Gql.Resolvers.SubListItemComment do
  alias ApiGatewayWeb.Gql.Utils.Errors
  alias ApiGateway.Models

  def get_sub_list_item_comment(_, %{where: %{id: sub_list_item_comment_id}}, _) do
    {:ok, Models.SubListItemComment.get_sub_list_item_comment(sub_list_item_comment_id)}
  end

  def get_sub_list_item_comments(_, %{where: filters}, _) do
    {:ok, Models.SubListItemComment.get_sub_list_item_comments(filters)}
  end

  def get_sub_list_item_comments(_, _, _) do
    {:ok, Models.SubListItemComment.get_sub_list_item_comments()}
  end

  def create_sub_list_item_comment(_, %{data: data}, _) do
    case Models.SubListItemComment.create_sub_list_item_comment(data) do
      {:ok, sub_list_item_comment} ->
        {:ok, sub_list_item_comment}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset(
          "SubListItemComment input error",
          errors
        )

      {:error, _} ->
        Errors.user_input_error("SubListItemComment input error")
    end
  end

  def update_sub_list_item_comment(_, %{data: data, where: %{id: id}}, _) do
    case Models.SubListItemComment.update_sub_list_item_comment(%{id: id, data: data}) do
      {:ok, sub_list_item_comment} ->
        {:ok, sub_list_item_comment}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset("SubListItemComment input error", errors)

      {:error, "Not found"} ->
        Errors.user_input_error("SubListItemComment not found")

      {:error, _} ->
        Errors.user_input_error("SubListItemComment input error")
    end
  end

  def delete_sub_list_item_comment(_, %{where: %{id: id}}, _) do
    case Models.SubListItemComment.delete_sub_list_item_comment(id) do
      {:ok, sub_list_item_comment} ->
        {:ok, sub_list_item_comment}

      {:error, "Not found"} ->
        Errors.user_input_error("SubListItemComment not found")
    end
  end

  ####################
  # Relation resolvers #
  ####################
end
