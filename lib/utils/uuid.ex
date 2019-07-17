defmodule Utils.UUID do
  @doc "will 'raise' if any list val is not a valid UUID"
  @spec cast_vals_to_uuid!(maybe_improper_list) :: [String.t()]
  def cast_vals_to_uuid!(list) when is_list(list) do
    Enum.map(list, fn val ->
      {:ok, val} = Ecto.UUID.cast(val)
      val
    end)
  end
end
