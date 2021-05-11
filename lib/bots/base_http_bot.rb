# frozen_string_literal: true
class BaseHTTPBot
  attr_reader :notifiers

  def initializer(notifiers: nil)
    @notifiers = notifiers
  end

  def poll
    raise NotImplementedError
  end
end
