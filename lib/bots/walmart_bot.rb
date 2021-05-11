# frozen_string_literal: true
class WalmartBot < BaseHTTPBot
  def notification
    {
      title: "Found appointments at Walmart",
      message: "TODO",
    }
  end

  class Response < BaseHTTPBot::Response
    def initialize
      @path = "http://" # TODO
      @headers = {}
      @http_method = :get
    end

    def available?
      # TODO
      false
    end
  end

  self.response_class = WalmartBot::Response
end
