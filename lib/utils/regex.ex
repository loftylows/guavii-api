defmodule Utils.Regex do
  @email_regex ~r/.+@.+\..+/i
  @subdomain_regex ~r{^([a-z0-9][a-z0-9-_]*\.)*[a-z0-9]*[a-z0-9-_]*[[a-z0-9]+$}

  def get_email_regex do
    @email_regex
  end

  def get_subdomain_regex do
    @subdomain_regex
  end
end
