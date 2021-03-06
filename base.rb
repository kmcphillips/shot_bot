# frozen_string_literal: true
require "pry"
require "active_support/all"
require "config"
require "logger"
require "httparty"
require "tempfile"
require "mail"
require "twilio-ruby"
require "securerandom"

# Inject all dependencies as exported globals
Global = Class.new do
  attr_accessor :root, :config, :logger, :bots, :notifiers, :error_notifiers
end.new

Global.root = Pathname.new(File.dirname(__FILE__))

Config.setup do |config|
  config.const_name = 'IgnoreMeGlobalConfiguration'
  config.evaluate_erb_in_yaml = false
end
Config.load_and_set_settings(Global.root.join("config/config.yml"))
Global.config = IgnoreMeGlobalConfiguration # Can't tell rubyconfig to not export a `const_name` so we just ignore it and pass it through

logger_file = File.open(Global.root.join("bot.log"), File::WRONLY | File::APPEND | File::CREAT)
logger_file.sync = true
Global.logger = Logger.new(logger_file, level: Logger::INFO)

Global.logger.extend(ActiveSupport::Logger.broadcast(Logger.new(STDOUT))) if Global.config.verbose

require_relative "lib/notifiers/base/notifier_base"
require_relative "lib/notifiers/console_notifier"
require_relative "lib/notifiers/email_notifier"
require_relative "lib/notifiers/sms_notifier"

require_relative "lib/bots/base/base_bot"
require_relative "lib/bots/base/base_http_bot_response"

require_relative "lib/bots/walmart_bot"
require_relative "lib/bots/shoppers_bot"
require_relative "lib/bots/twitter_search_bot"

require_relative "lib/runner"
require_relative "lib/runner_group"
