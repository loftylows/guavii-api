defmodule Utils.Regex do
  @email_regex ~r/.+@.+\..+/i

  def get_email_regex do
    @email_regex
  end
end
