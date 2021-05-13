# frozen_string_literal: true
class RunnerGroup
  attr_reader :config

  def initialize(config)
    @config = config
  end

  def run # TODO this only runs one for now
    Global.logger.info("Starting #{ config.count } #{ 'runner'.pluralize(config.count) }...")

    global_config = {
      interval_seconds: Global.config.interval_seconds, # TODO this could be moved to a different level
    }

    config.map do |runner_config|
      Runner.new(runner_config.to_h.merge(global_config)).run
    end
  end
end
