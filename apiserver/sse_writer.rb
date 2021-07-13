# frozen_string_literal: true

require 'json'

# This is thread-safe so that KeepAliver can write to it
# in a background thread.
class SSEWriter
  def initialize(stream)
    @stream = stream
    @mutex = Mutex.new
  end

  def write(data:, type: nil)
    @mutex.synchronize do
      @stream << "event: #{type}\n" if type
      @stream << "data: #{JSON.generate(data)}\n\n"
    end
  end
end
