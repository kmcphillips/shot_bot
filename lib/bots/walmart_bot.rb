# frozen_string_literal: true
class WalmartBot < BaseHTTPBot
  def notification
    {
      title: "Found appointment at Walmart South Keys",
      message: "Walmart at 2210 Bank St. has an appointment. https://portal.healthmyself.net/walmarton/forms/Dpd",
    }
  end

  class Response < BaseHTTPBot::Response
    def initialize
      @path = "https://portal.healthmyself.net/walmarton/guest/booking/4752/schedules?locId=1180"
      @headers = {
        "Cookie" => "hm_session=#{ Global.config.walmart_bot.cookie }",
      }
      @http_method = :get
    end

    def available?
      !!(result.body.index("next_date") || result.body.index("nextDate"))
    end
  end

  self.response_class = WalmartBot::Response
end
