# frozen_string_literal: true
module Notifier
  extend self

  def notify_all(notifiers:, message:, title:)
    Array(notifiers).each do |notifier_class|
      config = {} # TODO
      notifier_class.new(config).notify(message: message, title: title)
    end
  end
end
