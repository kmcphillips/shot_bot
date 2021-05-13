# frozen_string_literal: true
class EmailNotifier < NotifierBase
  def notify(title:, message:)
    Global.logger.info("[EmailNotifier] recipient=#{ config[:recipient_email] } title=#{ title } message=#{ message }")

    mail = Mail.new(
      to: config[:recipient_email],
      from: config[:smtp_from],
      subject: title,
      body: message,
      charset: 'UTF-8',
    )
    mail.delivery_method(:smtp, smtp_options)
    mail.deliver

    mail
  end

  private

  def smtp_options
    {
      address: config[:smtp_address],
      port: config[:smtp_port],
      domain: config[:smtp_domain],
      user_name: config[:smtp_username],
      password: config[:smtp_password],
      authentication: 'plain',
      enable_starttls_auto: true
    }
  end
end
