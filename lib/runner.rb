# frozen_string_literal: true
class Runner
  attr_reader :interval_seconds, :bots, :notifiers, :error_notifiers

  def initialize
    @interval_seconds = Global.config.interval_seconds
    @bots = Global.bots
    @notifiers = Global.notifiers
    @error_notifiers = Global.error_notifiers
  end

  def run
    Global.logger.info("Starting...")
    Global.logger.info("interval_seconds=#{ interval_seconds } bots=#{ bots } notifiers=#{ notifiers }")

    loop do
      bots.each do |bot_class|
        Global.logger.info("Running bot #{ bot_class }")
        bot = bot_class.new

        begin
          bot.poll
          if !bot.success?
            Notifier.notify_all(notifiers: error_notifiers, title: "Error HTTP #{ bot.response.code } #{ bot_class } ", message: "Could not complete request #{ bot } because HTTP #{ bot.response.code }.")
            Global.logger.debug("Failed request HTTP #{ bot.response.code } with #{ bot }\n#{ bot.response.result }")
          elsif bot.found?
            Global.logger.info("Found #{ bot } and notifying #{ notifiers }")
            Notifier.notify_all(notifiers: notifiers, title: bot.notification.title, message: bot.notification.message)
          end
        rescue => e
          Global.logger.error("Error with #{ bot } and notifying #{ error_notifiers }")
          Global.logger.error(e)
          error_message = "Error with #{ bot.inspect }\n\n#{ e.message }\n#{ e }"
          Notifier.notify_all(notifiers: error_notifiers, title: "Error with #{ bot_class }", message: error_message)
        end
      end

      Global.logger.info("Sleeping for #{ interval_seconds } seconds")
      sleep interval_seconds
    end
  end
end
