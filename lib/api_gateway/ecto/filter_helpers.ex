defmodule ApiGateway.Ecto.CommonFilterHelpers do
  require Ecto.Query
  alias Utils.UUID

  @spec maybe_first_filter(any, boolean()) :: Ecto.Query.t()
  def maybe_first_filter(query, bool) when is_boolean(bool) do
    query |> Ecto.Query.first()
  end

  def maybe_first_filter(query, _) do
    query
  end

  def maybe_id_in_filter(query, nil) do
    query
  end

  def maybe_id_in_filter(query, list) when is_list(list) do
    query |> Ecto.Query.where([p], p.id in ^UUID.cast_vals_to_uuid!(list))
  end

  def maybe_completed_filter(query, bool) when is_boolean(bool) do
    query |> Ecto.Query.where([p], p.completed == ^bool)
  end

  def maybe_completed_filter(query, _) do
    query
  end

  def maybe_distinct(query, nil) do
    query
  end

  def maybe_distinct(query, false) do
    query
  end

  def maybe_distinct(query, true) do
    query |> Ecto.Query.distinct(true)
  end

  def maybe_created_at_filter(query, date \\ nil)

  def maybe_created_at_filter(query, date) when is_nil(date) do
    query
  end

  def maybe_created_at_filter(query, date) do
    query |> Ecto.Query.where([p], p.inserted_at == ^date)
  end

  def maybe_created_at_gte_filter(query, date \\ nil)

  def maybe_created_at_gte_filter(query, date) when is_nil(date) do
    query
  end

  def maybe_created_at_gte_filter(query, date) do
    query |> Ecto.Query.where([p], p.inserted_at >= ^date)
  end

  def maybe_created_at_lte_filter(query, date \\ nil)

  def maybe_created_at_lte_filter(query, date) when is_nil(date) do
    query
  end

  def maybe_created_at_lte_filter(query, date) do
    query |> Ecto.Query.where([p], p.inserted_at <= ^date)
  end

  def maybe_due_date_filter(query, date \\ nil)

  def maybe_due_date_filter(query, date) when is_nil(date) do
    query
  end

  def maybe_due_date_filter(query, date) do
    query |> Ecto.Query.where([p], p.due_date == ^date)
  end

  def maybe_due_date_gte_filter(query, date \\ nil)

  def maybe_due_date_gte_filter(query, date) when is_nil(date) do
    query
  end

  def maybe_due_date_gte_filter(query, date) do
    query |> Ecto.Query.where([p], p.due_date >= ^date)
  end

  def maybe_due_date_lte_filter(query, date \\ nil)

  def maybe_due_date_lte_filter(query, date) when is_nil(date) do
    query
  end

  def maybe_due_date_lte_filter(query, date) do
    query |> Ecto.Query.where([p], p.due_date <= ^date)
  end

  def maybe_title_contains_filter(query, field \\ nil)

  def maybe_title_contains_filter(query, field) when is_binary(field) do
    query |> Ecto.Query.where([p], ilike(p.title, ^"%#{String.replace(field, "%", "\\%")}%"))
  end

  def maybe_title_contains_filter(query, _) do
    query
  end

  @doc "user_id must be a valid 'uuid' or an error will be raised"
  def maybe_user_id_assoc_filter(query, nil) do
    query
  end

  def maybe_user_id_assoc_filter(query, user_id) do
    query
    |> Ecto.Query.where([p], p.user_id == ^user_id)
  end

  @doc "project_id must be a valid 'uuid' or an error will be raised"
  def maybe_project_id_assoc_filter(query, nil) do
    query
  end

  def maybe_project_id_assoc_filter(query, project_id) do
    query
    |> Ecto.Query.where([p], p.project_id == ^project_id)
  end
end
