# frozen_string_literal: true
class BaseHTTPBot
  attr_reader :response

  def initialize
    @response = nil
  end

  def build_response
    raise NotImplementedError
  end

  def poll
    Global.logger.info("[#{ self.class }] #poll #{ response }")

    @response = build_response

    begin
      response.fetch

      if response.success?
        Global.logger.info("[#{ self.class }] success #{ response }")

        if response.found?
          Global.logger.info("[#{ self.class }] found!!!")
          # fall through and return true now
        else
          Global.logger.info("[#{ self.class }] not found")
        end
      else
        Global.logger.info("[#{ self.class }] failed #{ response }")
      end
    rescue => e
      Global.logger.error("[#{ self.class }] Error in #poll: #{ e.message }")
      Global.logger.error(e)
      raise # TODO handle error
    end

    found?
  end

  def found?
    response && response.success? && response.found?
  end

  def success?
    response && response.success?
  end

  def notification
    {
      title: "#{ self.class } found",
      message: "Found a dose with #{ self.class } #{ response }",
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

    def found?
      raise NotImplementedError
    end

    def to_s
      rescue_found = found? rescue nil
      "#<#{ self.class } code=#{ code } success=#{ success? } found=#{ rescue_found } #{ http_method.to_s.upcase } #{ path }>"
    end
  end
end
