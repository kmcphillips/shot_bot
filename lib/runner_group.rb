# frozen_string_literal: true
class RunnerGroup
  attr_reader :config

  def initialize(config)
    @config = config
  end

  def run
    Global.logger.info("Starting #{ config.count } #{ 'runner'.pluralize(config.count) }#{ config.count > 1 ? ' in threads' : '' }...")

    raise "Cannot run zero Runners." if config.size == 0

    if config.size == 1
      Runner.new(runner_config.to_h).run
    else
      threads = config.map do |runner_config|
        Thread.new do
          Runner.new(runner_config.to_h.merge(id: "thread-#{ Thread.current.object_id }")).run
        end
      end

      threads.each { |thread| thread.join }
    end
  end
end
