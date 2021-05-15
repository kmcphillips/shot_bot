# frozen_string_literal: true
class ShoppersBot < BaseBot
  def notification
    {
      title: "Found appointment at Shoppers",
      message: "Locations: #{ response.locations.join("\n")}",
    }
  end

  def build_response
    ShoppersBot::Response.new(results_per_page: config[:results_per_page], latitude: config[:latitude], longitude: config[:longitude])
  end

  class Response < BaseHttpBotResponse
    attr_reader :locations

    def initialize(results_per_page:, latitude:, longitude:)
      super()
      results_per_page = 24
      @path = "https://www1.shoppersdrugmart.ca/en/store/getstores?latitude=#{ latitude }&longitude=#{ longitude }&radius=500&unit=km&lookup=nearby&filters=RSV-CVW:TRUE,RSV-COV:TRUE&rpp=#{ results_per_page }&isCovidShotSearch=true&getCovidShotAvailability=true"
      puts @path
      @headers = {}
      @http_method = :get
      @locations = []
    end

    def found?
      begin
        json = JSON.parse(result.body)
      rescue => e
        Global.logger.error("[#{ self.class }] error parsing JSON from #{ path }")
        Global.logger.error(e)
        return false
      end

      json["results"].each do |json_result|
        if json_result["FlusShotAvailableNow"]
          Global.logger.info("[#{ self.class }] FlusShotAvailableNow=true #{ json_result }")
          address = [ json_result['address'], json_result['address2'], json_result['address3'], json_result['city'] ].reject(&:blank?).join(", ")
          location = "#{ json_result['name'] } (#{ json_result['storeType'] } ##{ json_result['storeNumber'] }) #{ address }"
          locations << location
        end
      end

      locations.any?
    end
  end
end
