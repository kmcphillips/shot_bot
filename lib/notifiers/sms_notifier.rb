# frozen_string_literal: true
class SMSNotifier
  def initialize
  end

  def notify(title:, message:)
    raise NotImplementedError, "SMSNotifier does not work yet"
  end
end
