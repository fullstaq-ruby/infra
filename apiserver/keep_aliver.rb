# frozen_string_literal: true

# Keeps an SSE stream alive by sending periodic pings.
class KeepAliver
  KEEPALIVE_INTERVAL = 15

  # @param sse_writer [SSEWriter]
  def self.run(sse_writer)
    keepaliver = new(sse_writer)
    begin
      keepaliver.start
      yield
    ensure
      keepaliver.shutdown
    end
  end

  def initialize(sse_writer)
    @writer = sse_writer
    @mutex = Mutex.new
    @cond = ConditionVariable.new
  end

  def start
    @thread = Thread.new do
      @mutex.synchronize do
        while !@quit
          @cond.wait(@mutex, KEEPALIVE_INTERVAL)
          ping if !@quit
        end
      end
    end
  end

  def shutdown
    @mutex.synchronize do
      @quit = true
      @cond.signal
    end
    @thread.join
  end

private
  def ping
    @mutex.unlock
    begin
      @writer.write(data: 'ping', type: :ping)
    ensure
      @mutex.lock
    end
  end
end
