defmodule ApiGatewayWeb.Gql.Utils.Errors do
  @authentication_error "UNAUTHENTICATED"
  @forbidden_error "FORBIDDEN"
  @user_input_error "BAD_USER_INPUT"
  @internal_error "INTERNAL_SERVER_ERROR"

  @doc """
  Provides an error with the provided message and optionally provided invalid args list
  """
  def user_input_error(msg, invalid_args \\ [])

  def user_input_error(msg, invalid_args)
      when is_binary(msg) and length(invalid_args) === 0 do
    {:error, message: msg, code: @user_input_error}
  end

  def user_input_error(msg, invalid_args)
      when is_binary(msg) and is_list(invalid_args) and length(invalid_args) > 0 do
    {:error, message: msg, code: @user_input_error, details: %{invalid_args: invalid_args}}
  end

  def authentication_error(msg \\ "Authentication required") when is_binary(msg) do
    {:error, message: msg, code: @authentication_error}
  end

  def forbidden_error(msg \\ "Forbidden request") when is_binary(msg) do
    {:error, message: msg, code: @forbidden_error}
  end

  def internal_error(msg \\ "An internal error occurred") when is_binary(msg) do
    {:error, message: msg, code: @internal_error}
  end
end
