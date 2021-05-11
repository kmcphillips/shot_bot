# frozen_string_literal: true
class ConsoleNotifier
  def notify(title:, message:)
    output = "[ConsoleNotifier] title:#{ title } message:#{ message }"
    puts output
    Global.logger.info(output)
  end
end
