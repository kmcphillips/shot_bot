# frozen_string_literal: true
class BaseBot
  attr_reader :response, :config

  def initialize(config={})
    @config = config
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
          Global.logger.info("[#{ self.class }] found!")
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
end
