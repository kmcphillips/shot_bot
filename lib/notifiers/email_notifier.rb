# frozen_string_literal: true
Mail.defaults do
  delivery_method :smtp, {
    address: Global.config.email.smtp_address,
    port: Global.config.email.smtp_port,
    domain: Global.config.email.smtp_domain,
    user_name: Global.config.email.smtp_username,
    password: Global.config.email.smtp_password,
    authentication: 'plain',
    enable_starttls_auto: true
  }
end

class EmailNotifier
  def initialize
  end

  def notify(title:, message:)
    Global.logger.info("[EmailNotifier] title:#{ title } message:#{ message }")

    mail = Mail.new(
      to: Global.config.email.email_notifier_recipient,
      from: Global.config.email.smtp_from,
      subject: title,
      body: message,
      charset: 'UTF-8',
    )
    mail.deliver
  end
end
