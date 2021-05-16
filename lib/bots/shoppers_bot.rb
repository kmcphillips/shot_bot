# frozen_string_literal: true
class ShoppersBot < BaseBot
  def notification
    {
      title: "Found appointment at Shoppers",
      message: "Locations: #{ response.locations.join("\n")}",
    }
  end

  def build_response
    ShoppersBot::Response.new(results_per_page: config[:results_per_page], latitude: config[:latitude], longitude: config[:longitude], store_numbers: config[:store_numbers])
  end

  class Response < BaseHttpBotResponse
    attr_reader :locations, :store_numbers

    def initialize(results_per_page:, latitude:, longitude:, store_numbers: nil)
      super()
      results_per_page = 24
      @path = "https://www1.shoppersdrugmart.ca/en/store/getstores?latitude=#{ latitude }&longitude=#{ longitude }&radius=500&unit=km&lookup=nearby&filters=RSV-CVW:TRUE,RSV-COV:TRUE&rpp=#{ results_per_page }&isCovidShotSearch=true&getCovidShotAvailability=true"
      @headers = {}
      @http_method = :get
      @locations = nil
      @store_numbers = store_numbers
      @store_numbers = @store_numbers.map { |n| n.presence&.to_i }.compact if @store_numbers
    end

    def found?
      return locations.any? if locations
      @locations = []

      begin
        json = JSON.parse(result.body)
      rescue => e
        Global.logger.error("[#{ self.class }] error parsing JSON from #{ path }")
        Global.logger.error(e)
        return false
      end

      json_results = json["results"]

      if store_numbers && store_numbers.any?
        json_results = json_results.select { |json_result| store_numbers.include?(json_result['storeNumber'].to_i) }
        Global.logger.info("[#{ self.class }] store_numbers=#{ store_numbers } limited to #{ json_results.count } #{ 'store'.pluralize(json_results.count) }")
      end

      json_results.each do |json_result|
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
