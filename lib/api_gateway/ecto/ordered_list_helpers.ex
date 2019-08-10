defmodule ApiGateway.Ecto.OrderedListHelpers do
  require Ecto.Query
  import Ecto.Query, only: [from: 2]

  # TODO: Fix the possible race condition in this case
  def get_insert_rank(prev, next) when is_float(prev) and is_float(next) do
    # in between
    (prev + next) / 2.0
  end

  # TODO: Fix the possible race condition in this case
  def get_insert_rank(prev, next) when is_nil(prev) and is_float(next) do
    # first
    next / 2.0
  end

  def get_insert_rank(prev, next) when is_float(prev) and is_nil(next) do
    # last
    prev + (1.0 + :rand.uniform(1000)) / 1
  end

  def get_insert_rank(prev, next) when is_nil(prev) and is_nil(next) do
    # only item
    (1.0 + :rand.uniform(1000)) / 1
  end

  def gap_acceptable?(prev, next) when is_float(prev) and is_float(next) do
    gap = next - prev

    gap > 0 and gap > 0.0000000005
  end

  def gap_acceptable?(nil, next) when is_float(next) do
    gap = next - 0

    gap > 0 and gap > 0.0000000005
  end

  def gap_acceptable?(_, _) do
    true
  end

  defmodule DB do
    # TODO: Fix this query to only include the items with the particular relation that we want.
    # row number should not have to count other items too that do not have this relation because this
    # will slow the query down
    @doc """
    Uses a raw SQL query to normalize positions attributes (field name given by 'rank_field_name')
    of items supposed to be in an ordered list. sorts the fields, based on the 'rank_field_name',
    amd then sets the 'rank_field_name' based on the ROW_NUMBER sql window function
    """
    @spec normalize_list_order(String.t(), String.t(), String.t(), String.t()) ::
            {:ok, any()} | {:error, any()}
    def normalize_list_order(table_name, rank_field_name, relation_id_field, relation_id)
        when is_binary(table_name) do
      query = """
      UPDATE #{table_name} item
      SET    #{rank_field_name} = sub.row_num
      FROM  (SELECT id, CAST (row_number() OVER (PARTITION BY #{relation_id_field} ORDER BY #{
        rank_field_name
      } ASC) AS FLOAT) AS row_num FROM #{table_name}) sub
      WHERE (item.id = sub.id) AND (item.#{relation_id_field} = '#{relation_id}');
      """

      case Ecto.Adapters.SQL.query(ApiGateway.Repo, query, []) do
        {:ok, changes} ->
          {:ok, changes}

        {:error, exception} ->
          {:error, exception}
      end
    end

    def get_new_item_insert_rank(table_name_or_schema, relation_id, relation_id_field)
        when is_binary(relation_id) do
      query =
        from x in table_name_or_schema,
          where: field(x, ^relation_id_field) == ^relation_id,
          select: max(x.list_order_rank)

      case ApiGateway.Repo.one(query) do
        nil -> (1.0 + :rand.uniform(1000)) / 1
        value -> (value || 0.0) + (1.0 + :rand.uniform(1000)) / 1
      end
    end
  end
end
