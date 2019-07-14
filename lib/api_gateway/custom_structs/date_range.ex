defmodule ApiGateway.CustomStructs.DateRange do
  @enforce_keys [:start, :end]
  defstruct [:start, :end]
end
