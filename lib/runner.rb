# frozen_string_literal: true
class Runner
  attr_reader :interval_seconds, :bots, :success_notifiers, :error_notifiers, :id

  def initialize(config)
    @id = config[:id].presence || SecureRandom.hex(4)
    @interval_seconds = config[:interval_seconds]
    @bots = config[:bots]
    @success_notifiers = config[:success_notifiers]
    @error_notifiers = config[:error_notifiers]
  end

  def run
    Global.logger.info("[Runner][#{ id }] starting interval_seconds=#{ interval_seconds } bots=#{ bots.map { |x| x[:class] } } success_notifiers=#{ success_notifiers.map { |x| x[:class] } } error_notifiers=#{ error_notifiers.map { |x| x[:class] } }")

    loop do
      bots.each do |bot_config|
        bot_class = bot_config[:class].to_s.constantize
        Global.logger.info("[Runner][#{ id }] bot #{ bot_class }")
        bot = bot_class.new(bot_config)

        begin
          bot.poll
          if !bot.success?
            Global.logger.debug("[Runner][#{ id }] Failed request HTTP #{ bot.response.code } with #{ bot }\n#{ bot.response.result }")
            notify_all(
              notifiers: error_notifiers,
              title: "Error HTTP #{ bot.response.code } #{ bot_class }",
              message: "Could not complete request #{ bot } because HTTP #{ bot.response.code }."
            )
          elsif bot.found?
            Global.logger.info("[Runner][#{ id }] Found #{ bot } and notifying #{ success_notifiers.map { |x| x[:class] } }")
            notify_all(notifiers: success_notifiers, title: bot.notification[:title], message: bot.notification[:message])
          end
        rescue => e
          Global.logger.error("[Runner][#{ id }] Error with #{ bot } and notifying #{ error_notifiers.map { |x| x[:class] } }")
          Global.logger.error(e)
          error_message = "Error with #{ bot.inspect }\n\n#{ e.message }\n#{ e }"
          notify_all(notifiers: error_notifiers, title: "Error with #{ bot_class }", message: error_message)
        end
      end

      Global.logger.info("[Runner][#{ id }] Sleeping for #{ interval_seconds } seconds")
      sleep(interval_seconds)
    end
  end

  private

  def to_class_config_hash(input)
    input.to_h{|klass, config| [klass.to_s.constantize, config] }
  end

  def notify_all(notifiers:, title:, message:)
    notifiers.map do |notifier_config|
      notifier_config[:class].to_s.constantize.new(notifier_config).notify(title: title, message: message)
    end
  end
end

