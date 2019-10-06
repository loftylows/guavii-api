defmodule ApiGateway.Mailer do
  use Bamboo.Mailer, otp_app: :api_gateway

  def supports_attachments, do: false
end
