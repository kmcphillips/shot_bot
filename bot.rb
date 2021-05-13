# frozen_string_literal: true

require_relative "base"

RunnerGroup.new(Global.config.runners).run
