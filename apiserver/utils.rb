# frozen_string_literal: true

require 'json'
require 'openssl'
require 'open3'
require 'socket'

class Utils
  def run_command(*command)
    begin
      _, stderr_output, status = Open3.capture3(*command)
    rescue SystemCallError => e
      return e
    end

    return RuntimeError.new(stderr_output.chomp) if !status.success?

    nil
  end

  def run_command_stream_output(*command)
    Open3.popen2e(*command) do |stdin, output, waiter|
      stdin.close
      while !output.eof?
        yield output.readline
      end
      waiter.value.success?
    end
  end


  if defined?(OpenSSL.fixed_length_secure_compare)
    def fixed_length_secure_compare(a, b)
      OpenSSL.fixed_length_secure_compare(a, b)
    end
  else
    def fixed_length_secure_compare(a, b)
      raise ArgumentError, 'string length mismatch' unless a.bytesize == b.bytesize

      l = a.unpack "C#{a.bytesize}"

      res = 0
      b.each_byte { |byte| res |= byte ^ l.shift }
      res == 0
    end
  end

  def secure_compare(a, b)
    a.length == b.length && fixed_length_secure_compare(a, b)
  end

  # Works around https://issuetracker.google.com/issues/187448830
  def uncork_socket(rack_env)
    return if !defined?(Socket::IPPROTO_TCP) || !defined?(Socket::TCP_CORK)
    socket = rack_env['puma.socket']
    return if socket.nil?
    socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_CORK, 0)
  end
end
