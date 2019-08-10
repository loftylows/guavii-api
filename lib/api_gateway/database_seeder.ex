defmodule ApiGateway.DatabaseSeeder do
  alias ApiGateway.Repo
  alias ApiGateway.Models.InternalSubdomain

  @protected_subdomains [
    [subdomain: "www"],
    [subdomain: "proxy"],
    [subdomain: "www.proxy"],
    [subdomain: "info"],
    [subdomain: "www.info"],
    [subdomain: "meta"],
    [subdomain: "www.meta"],
    [subdomain: "cdn"],
    [subdomain: "www.cdn"],
    [subdomain: "download"],
    [subdomain: "www.download"],
    [subdomain: "admin"],
    [subdomain: "www.admin"],
    [subdomain: "internal"],
    [subdomain: "www.internal"],
    [subdomain: "public"],
    [subdomain: "www.public"],
    [subdomain: "private"],
    [subdomain: "www.private"],
    [subdomain: "platform"],
    [subdomain: "www.platform"],
    [subdomain: "api"],
    [subdomain: "www.api"],
    [subdomain: "guavii"],
    [subdomain: "www.guavii"],
    [subdomain: "external"],
    [subdomain: "www.external"],
    [subdomain: "console"],
    [subdomain: "www.console"],
    [subdomain: "app"],
    [subdomain: "www.app"],
    [subdomain: "application"],
    [subdomain: "www.application"],
    [subdomain: "forum"],
    [subdomain: "www.forum"],
    [subdomain: "dev"],
    [subdomain: "www.dev"],
    [subdomain: "docs"],
    [subdomain: "www.docs"],
    [subdomain: "testing"],
    [subdomain: "www.testing"]
  ]

  def insert_protected_subdomains do
    now =
      DateTime.utc_now()
      |> DateTime.truncate(:second)

    items =
      @protected_subdomains
      |> Enum.map(fn item -> List.flatten([item, [inserted_at: now, updated_at: now]]) end)

    Repo.insert_all(InternalSubdomain, items)
  end
end
