defmodule Utils.Float do
  def get_float_precision(float) when is_float(float) do
    length =
      (float - Float.floor(float))
      |> to_charlist()
      |> length()

    length - 2
  end
end
