module Kernel

  # Figures out which form_for method is calling our fields_for method, but can be used for other
  # situations as well.
  def caller_method(level = 1)
    caller[level] =~ /`([^']*)'/ and $1
  end

  # Provides a handy trace style method that you can use anywhere.
  def log_trace(message)
    custom_logger = Logger.new('log/trace.log')
    if message.respond_to?(:inspect)
      message = message.inspect
    end
    custom_logger.add(Logger::INFO, "#{Time.now} in #{caller[0]}:\n#{message}\n")
  end

end
