# frozen_string_literal: true
class Runner
  attr_reader :interval_seconds, :bots, :notifiers, :verbose

  def initialize(verbose: false)
    @interval_seconds = Global.config.interval_seconds
    @bots = Global.config.bots
    @notifiers = Global.config.notifiers
    @verbose = verbose
  end

  def run
    log "Starting..."
    log "interval_seconds=#{ interval_seconds } bots=#{ bots } notifiers=#{ notifiers }"

    loop do
      bots.each do |bot|
        log "Running bot #{ bot }"
        bot.new(notifiers: notifiers).poll
      end

      log "Sleeping for #{ interval_seconds } seconds"
      sleep interval_seconds
    end
  end

  private

  def log(message)
    Global.logger.info("[Runner] #{ message }")
    puts "[Runner][#{ Time.now.strftime(Global.datetime_format) }] #{ message }" if verbose
    nil
  end
end
