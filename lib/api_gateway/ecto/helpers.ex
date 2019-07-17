defmodule ApiGateway.Ecto.CommonFilterHelpers do
  require Ecto.Query
  alias Utils.UUID

  def maybe_id_in_filter(query, list \\ [])

  def maybe_id_in_filter(query, list) when is_list(list) and length(list) > 0 do
    query |> Ecto.Query.where([p], p.id in ^UUID.cast_vals_to_uuid!(list))
  end

  def maybe_id_in_filter(query, _) do
    query
  end

  def maybe_created_at_filter(query, date) when is_nil(date) do
    query
  end

  def maybe_created_at_filter(query, date) do
    query |> Ecto.Query.where([p], p.inserted_at == ^date)
  end

  def maybe_created_at_gte_filter(query, date) when is_nil(date) do
    query
  end

  def maybe_created_at_gte_filter(query, date) do
    query |> Ecto.Query.where([p], p.inserted_at >= ^date)
  end

  def maybe_created_at_lte_filter(query, date) when is_nil(date) do
    query
  end

  def maybe_created_at_lte_filter(query, date) do
    query |> Ecto.Query.where([p], p.inserted_at <= ^date)
  end
end
