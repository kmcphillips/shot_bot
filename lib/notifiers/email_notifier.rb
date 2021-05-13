# frozen_string_literal: true
class EmailNotifier < NotifierBase
  def notify(title:, message:)
    Global.logger.info("[EmailNotifier] recipient=#{ recipient } title=#{ title } message=#{ message }")

    mail = Mail.new(
      to: recipient,
      from: sender,
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
      address: Global.config.email.smtp_address,
      port: Global.config.email.smtp_port,
      domain: Global.config.email.smtp_domain,
      user_name: Global.config.email.smtp_username,
      password: Global.config.email.smtp_password,
      authentication: 'plain',
      enable_starttls_auto: true
    }
  end

  def recipient
    Global.config.email.email_notifier_recipient
  end

  def sender
    Global.config.email.smtp_from
  end
end
