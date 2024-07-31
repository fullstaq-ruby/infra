#!/usr/bin/env ruby
require 'net/http'
require 'net/https'

def main
  open_io(ARGV[0]) do |io|
    query_repo_version('apt', io)
    query_repo_version('yum', io)
  end
end

def query_repo_version(type, output)
  uri = URI("https://storage.googleapis.com/#{require_env(:GCLOUD_BUCKET_PREFIX)}-server-edition-#{type}-repo/versions/latest_version.txt")

  STDERR.puts "Querying #{uri}..."
  req = Net::HTTP::Get.new(uri)
  req['Cache-Control'] = 'no-cache, no-store'

  resp = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(req)
  end

  if resp.code.to_i / 100 != 2
    abort("Failed to query #{uri}: #{resp.code} #{resp.body}")
  end

  STDERR.puts "#{type} latest version: #{resp.body}"
  output.puts "#{type.upcase}_LATEST_VERSION=#{resp.body}"
end

def open_io(path)
  if path.nil? || path == '-'
    yield($stdout)
  else
    File.open(path, 'w:utf-8') do |io|
      yield(io)
    end
  end
end

def require_env(name)
  ENV[name.to_s] || abort("Missing required environment variable: #{name}")
end

main
