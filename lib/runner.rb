# frozen_string_literal: true
class Runner
  attr_reader :interval_seconds, :bots, :notifiers

  def initialize
    @interval_seconds = Global.config.interval_seconds
    @bots = Global.bots
    @notifiers = Global.notifiers
  end

  def run
    Global.logger.info "Starting..."
    Global.logger.info "interval_seconds=#{ interval_seconds } bots=#{ bots } notifiers=#{ notifiers }"

    loop do
      bots.each do |bot_class|
        Global.logger.info "Running bot #{ bot_class }"
        bot_class.new(notifiers: notifiers).poll
      end

      Global.logger.info "Sleeping for #{ interval_seconds } seconds"
      sleep interval_seconds
    end
  end
end
