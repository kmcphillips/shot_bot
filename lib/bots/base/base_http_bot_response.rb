# frozen_string_literal: true
class BaseHttpBotResponse
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

  def error_message
    "HTTP #{ code }" if !success? && code
  end

  def found?
    raise NotImplementedError
  end

  def to_s
    rescue_found = found? rescue nil
    "#<#{ self.class } code=#{ code } success=#{ success? } found=#{ rescue_found } #{ http_method.to_s.upcase } #{ path }>"
  end
end
