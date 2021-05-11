# frozen_string_literal: true
module Notifier
  extend self

  def notify_all(notifiers:, message:, title:)
    Array(notifiers).each do |notifier_class|
      notifier_class.new.notify(message: message, title: title)
    end
  end
end
