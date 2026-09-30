#!/usr/bin/env ruby
require 'net/http'
require 'net/https'

def main
  open_io(ARGV[0]) do |io|
    query_repo_version('apt', io)
    query_repo_version('yum', io)
    query_repo_version('apt-archive', io, allow_missing: true)
    query_repo_version('yum-archive', io, allow_missing: true)
    io.puts "REPO_QUERY_TIME=#{Time.now.to_f}"
  end
end

def query_repo_version(type, output, allow_missing: false)
  env_key = type.upcase.tr('-', '_')
  uri = URI("https://storage.googleapis.com/#{require_env(:GCLOUD_BUCKET_PREFIX)}-server-edition-#{type}-repo/versions/latest_version.txt")

  STDERR.puts "Querying #{uri}..."
  req = Net::HTTP::Get.new(uri)
  req['Cache-Control'] = 'no-cache, no-store'

  resp = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(req)
  end

  if resp.code.to_i / 100 != 2
    # Archive buckets may legitimately not be populated before the first
    # migration runs. Only treat 404 as the "not yet populated" case; any
    # other non-2xx (auth, 5xx, redirects) is a real failure and must surface
    # — silently falling back to version 0 would point clients at
    # /versions/0/... 404s.
    if allow_missing && resp.code.to_i == 404
      STDERR.puts "Warning: #{type} repo not found (404), skipping"
      output.puts "#{env_key}_LATEST_VERSION=0"
      return
    end
    abort("Failed to query #{uri}: #{resp.code} #{resp.body}")
  end

  STDERR.puts "#{type} latest version: #{resp.body}"
  output.puts "#{env_key}_LATEST_VERSION=#{resp.body}"
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
