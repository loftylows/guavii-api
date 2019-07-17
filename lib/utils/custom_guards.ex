defmodule Utils.CustomGuards do
  defguard empty_map?(map) when map_size(map) == 0
end
