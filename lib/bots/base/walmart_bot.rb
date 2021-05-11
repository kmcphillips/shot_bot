# frozen_string_literal: true
class WalmartBot < BaseHTTPBot
  class Response < BaseHTTPBot::Response
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
