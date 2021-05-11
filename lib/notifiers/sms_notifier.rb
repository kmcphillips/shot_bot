# frozen_string_literal: true
class SMSNotifier
  def notify(title:, message:)
    full_message = [title, message].map(&:presence).compact.join(" ")

    Global.logger.info("[SMSNotifier] Sending #{ recipient_phone_number }: #{ full_message }")

    response = twilio_client.messages.create(
      from: outgoing_phone_number,
      to: recipient_phone_number,
      body: message,
    )

    Global.logger.info("[SMSNotifier] sid=#{ response.sid }")

    response.sid
  end

  private

  def twilio_client
    @twilio_client ||= Twilio::REST::Client.new(account_sid, auth_token)
  end

  def account_sid
    Global.config.sms.twilio_account_sid
  end

  def auth_token
    Global.config.sms.twilio_auth_token
  end

  def outgoing_phone_number
    Global.config.sms.outgoing_phone_number
  end

  def recipient_phone_number
    Global.config.sms.recipient_phone_number
  end
end
