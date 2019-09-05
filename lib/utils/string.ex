defmodule Utils.String do
  @spec title_capitalize(String.t()) :: String.t()
  def title_capitalize(item) when is_binary(item) do
    for word <- String.split(item) do
      case Regex.match?(~r/[a-z]/, String.slice(word, 0..1)) do
        false ->
          word

        true ->
          String.capitalize(word)
      end
    end
    |> Enum.join(" ")
  end
end
