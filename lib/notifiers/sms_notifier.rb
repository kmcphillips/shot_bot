# frozen_string_literal: true
class SMSNotifier < NotifierBase
  def notify(title:, message:)
    full_message = [title, message].map(&:presence).compact.join(" ")

    Global.logger.info("[SMSNotifier] Sending #{ config[:recipient_phone_number] }: #{ full_message }")

    response = twilio_client.messages.create(
      from: config[:outgoing_phone_number],
      to: config[:recipient_phone_number],
      body: full_message,
    )

    Global.logger.info("[SMSNotifier] sid=#{ response.sid }")

    response.sid
  end

  private

  def twilio_client
    @twilio_client ||= Twilio::REST::Client.new(config[:twilio_account_sid], config[:twilio_auth_token])
  end
end
