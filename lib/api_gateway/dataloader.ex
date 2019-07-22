defmodule ApiGateway.Dataloader do
  def data() do
    Dataloader.Ecto.new(ApiGateway.Repo, query: &query/2)
  end

  def query(queryable, _params) do
    queryable
  end
end
