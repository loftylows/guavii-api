defmodule ApiGatewayWeb.Gql.Schema.CommonInputTypes do
  use Absinthe.Schema.Notation

  input_object :date_range_input do
    field :start, non_null(:iso_date_time)
    field :end, non_null(:iso_date_time)
  end
end
