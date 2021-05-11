# frozen_string_literal: true
class BaseHTTPBot
  attr_reader :notifiers, :response, :response_class
  class_attribute :response_class

  def initialize(notifiers: nil)
    @notifiers = notifiers
    @response = self.class.response_class.new
  end

  attr_reader :response

  def poll
    Global.logger.info("[#{ self.class }] #poll #{ response }")

    begin
      response.fetch

      if response.success?
        Global.logger.info("[#{ self.class }] success #{ response }")

        if response.available?
          Global.logger.info("[#{ self.class }] available!!!")

          notifiers.each do |notifier_class|
            Global.logger.info("[#{ self.class }] delivering notification to #{ notifier_class }")
            notifier_class.new.notify(**notification)
          end
        else
          Global.logger.info("[#{ self.class }] not available")
        end
      else
        Global.logger.info("[#{ self.class }] failed #{ response }")
      end
    rescue => e
      Global.logger.error("[#{ self.class }] Error in #poll: #{ e.message }")
      Global.logger.error(e)
      # TODO handle error
    end
  end

  def notification
    {
      title: "#{ self.class } available",
      message: "Found a dose available with #{ self.class } #{ response }",
    }
  end

  class Response
    attr_reader :result, :path, :headers, :http_method

    def initialize
      @result = nil
      @path = nil
      @headers = {}
      @http_method = :get
    end

    def fetch
      if http_method.to_s.downcase == "get"
        @result = HTTParty.get(path, headers: headers)
      elsif http_method.to_s.downcase == "post"
        @result = HTTParty.post(path, headers: headers)
      else
        raise "Unknown http_method #{ http_method }"
      end

      success?
    end

    def success?
      !!(result && result.success?)
    end

    def code
      result && result.code
    end

    def available?
      raise NotImplementedError
    end

    def to_s
      rescue_avail = available? rescue nil
      "#<#{ self.class } code=#{ code } success=#{ success? } available=#{ rescue_avail } #{ http_method.to_s.upcase } #{ path }>"
    end
  end
end
