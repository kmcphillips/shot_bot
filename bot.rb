# frozen_string_literal: true

require_relative "base"
require_relative "lib/runner"

Runner.new(verbose: Global.config.verbose).run
