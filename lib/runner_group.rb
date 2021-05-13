# frozen_string_literal: true
class RunnerGroup
  attr_reader :config

  def initialize(config)
    @config = config
  end

  def run
    Global.logger.info("Starting #{ config.count } #{ 'runner'.pluralize(config.count) }...")

    global_config = {
      interval_seconds: Global.config.interval_seconds, # TODO this could be moved to a different level
    }

    raise "Cannot run zero Runners." if config.size == 0
    raise "Cannot run more than one Runner for now. I have no idea if any of this is thread safe." if config.size > 1  # TODO this only runs one for now

    config.map do |runner_config|
      Runner.new(runner_config.to_h.merge(global_config)).run
    end
  end
end
