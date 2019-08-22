defmodule ApiGateway.CustomEctoTypes.EctoDateRange do
  @behaviour Ecto.Type
  def type, do: :map

  @enforce_keys [:start, :end]
  defstruct [:start, :end]

  # Provide custom casting rules.
  # Cast strings into the DateRange struct to be used at runtime
  def cast(%{start: startDate, end: endDate})
      when is_binary(startDate) and is_binary(endDate) do
    case {DateTime.from_iso8601(startDate), DateTime.from_iso8601(endDate)} do
      {{:ok, date_time_start, _}, {:ok, date_time_end, _}} ->
        {:ok, %ApiGateway.CustomStructs.DateRange{start: date_time_start, end: date_time_end}}

      _ ->
        {:error, "Start and end dates must be iso8601 strings"}
    end
  end

  def cast(%{start: %DateTime{}, end: %DateTime{}} = date_range) do
    {:ok, struct!(ApiGateway.CustomStructs.DateRange, date_range)}
  end

  # Everything else is a failure though
  def cast(_) do
    :error
  end

  # When loading data from the database, we are guaranteed to
  # receive a map (as databases are strict) and we will
  # just put the data back into an DateRange struct to be stored
  # in the loaded schema struct.
  def load(%{"start" => startDate, "end" => endDate}) do
    case {DateTime.from_iso8601(startDate), DateTime.from_iso8601(endDate)} do
      {{:ok, date_time_start, _}, {:ok, date_time_end, _}} ->
        {:ok, %ApiGateway.CustomStructs.DateRange{start: date_time_start, end: date_time_end}}

      _ ->
        {:error, "Start and end dates must be iso8601 strings"}
    end
  end

  # When dumping data to the database, we *expect* an DateRange struct
  # but any value could be inserted into the schema struct at runtime,
  # so we need to guard against them.
  def dump(%ApiGateway.CustomStructs.DateRange{} = date_range) do
    {:ok, Map.from_struct(date_range)}
  end

  def dump(_), do: :error
end
