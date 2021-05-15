# frozen_string_literal: true
class WalmartBot < BaseBot
  def notification
    {
      title: "Found appointment at Walmart #{ config[:location_name] }",
      message: "Walmart at #{ config[:location_address] } has an appointment. https://portal.healthmyself.net/walmarton/forms/Dpd",
    }
  end

  def build_response
    WalmartBot::Response.new(
      location_id: config[:location_id],
      hm_session_cookie: config[:cookie]
    )
  end

  def bot_name
    config[:location_name]
  end

  class Response < BaseHttpBotResponse
    def initialize(location_id:, hm_session_cookie:)
      super()
      @path = "https://portal.healthmyself.net/walmarton/guest/booking/4752/schedules?locId=#{ location_id }"
      @headers = {
        "Cookie" => "hm_session=#{ hm_session_cookie }",
      }
      @http_method = :get
    end

    def found?
      !!(result.body.index("next_date") || result.body.index("nextDate"))
    end
  end
end
