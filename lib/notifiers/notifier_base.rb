# frozen_string_literal: true
class NotifierBase
  attr_reader :config

  def initialize(config={})
    @config = config
  end

  def notify(title:, message:)
    raise NotImplementedError
  end
end
