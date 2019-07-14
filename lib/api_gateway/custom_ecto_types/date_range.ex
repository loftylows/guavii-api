defmodule ApiGateway.CustomEctoTypes.EctoDateRange do
  @behaviour Ecto.Type
  def type, do: :map

  @enforce_keys [:start, :end]
  defstruct [:start, :end]

  # Provide custom casting rules.
  # Cast strings into the URI struct to be used at runtime
  def cast(%{start: startDate, end: endDate}) when is_binary(startDate) and is_binary(endDate) do
    case {Date.from_iso8601(startDate), Date.from_iso8601(endDate)} do
      {{:ok, _}, {:ok, _}} ->
        {:ok, %ApiGateway.CustomStructs.DateRange{start: startDate, end: endDate}}

      _ ->
        {:error, "Start and end dates must be iso8601 strings"}
    end
  end

  # Accept casting of DateRange structs as well
  def cast(%ApiGateway.CustomStructs.DateRange{start: startDate, end: endDate} = date_range)
      when is_binary(startDate) and is_binary(endDate) do
    case {Date.from_iso8601(startDate), Date.from_iso8601(endDate)} do
      {{:ok, _}, {:ok, _}} ->
        {:ok, date_range}

      _ ->
        {:error, "Start and end dates must be iso8601 strings"}
    end
  end

  # Everything else is a failure though
  def cast(_), do: :error

  # When loading data from the database, we are guaranteed to
  # receive a map (as databases are strict) and we will
  # just put the data back into an URI struct to be stored
  # in the loaded schema struct.
  def load(data) when is_map(data) do
    data =
      for {key, val} <- data do
        {String.to_existing_atom(key), val}
      end

    {:ok, struct!(ApiGateway.CustomStructs.DateRange, data)}
  end

  # When dumping data to the database, we *expect* an URI struct
  # but any value could be inserted into the schema struct at runtime,
  # so we need to guard against them.
  def dump(%ApiGateway.CustomStructs.DateRange{start: startDate, end: endDate} = date_range)
      when is_binary(startDate) and is_binary(endDate) do
    case {Date.from_iso8601(startDate), Date.from_iso8601(endDate)} do
      {{:ok, _}, {:ok, _}} ->
        {:ok, Map.from_struct(date_range)}

      _ ->
        {:error, "Start and end dates must be iso8601 strings"}
    end
  end

  def dump(_), do: :error
end
