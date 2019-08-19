defmodule ApiGateway.Dataloader do
  require Ecto.Query

  alias ApiGateway.Models.Project

  def data() do
    Dataloader.Ecto.new(ApiGateway.Repo, query: &query/2)
  end

  def query(Project = queryable, _params) do
    queryable
    |> Ecto.Query.preload(:kanban_board)
    |> Ecto.Query.preload(:lists_board)
  end

  def query(queryable, _params) do
    queryable
  end
end
