defmodule ApiGatewayWeb.Gql.Utils.Errors do
  @authentication_error "UNAUTHENTICATED"
  @forbidden_error "FORBIDDEN"
  @user_input_error "BAD_USER_INPUT"
  @internal_error "INTERNAL_SERVER_ERROR"

  @doc """
  Provides an error with the given message and optionally provided details messages list
  """
  def user_input_error(msg, invalid_args \\ [])

  def user_input_error(msg, invalid_args)
      when is_binary(msg) and is_list(invalid_args) and length(invalid_args) === 0 do
    {:error, message: msg, code: @user_input_error}
  end

  def user_input_error(msg, error_detail_messages)
      when is_binary(msg) and is_list(error_detail_messages) and length(error_detail_messages) > 0 do
    errors =
      Enum.map(error_detail_messages, fn details ->
        %{
          message: msg,
          code: @user_input_error,
          details: details
        }
      end)

    {:error, errors}
  end

  @doc """
  Turns Ecto changeset errors into a gql error with a list of validation errors
  """
  def user_input_error_from_changeset(msg, invalid_args \\ [])

  def user_input_error_from_changeset(msg, invalid_args)
      when is_binary(msg) and is_list(invalid_args) and length(invalid_args) === 0 do
    {:error, message: msg, code: @user_input_error}
  end

  def user_input_error_from_changeset(msg, invalid_args)
      when is_binary(msg) and is_list(invalid_args) and length(invalid_args) > 0 do
    errors =
      Enum.map(invalid_args, fn {field, {msg_String, _}} ->
        %{
          message: msg,
          code: @user_input_error,
          field: field,
          field_details: msg_String
        }
      end)

    {:error, errors}
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
