# frozen_string_literal: true

require 'jwt'
require 'net/http'
require 'sinatra/base'

class App < Sinatra::Base
  GITHUB_ACTIONS_OIDC_ISSUER_URL = 'https://token.actions.githubusercontent.com'
  GITHUB_JWKS_URL = 'https://token.actions.githubusercontent.com/.well-known/jwks'
  EXPECTED_AUDIENCE_CLAIM = 'backend.fullstaqruby.org'

  get '/' do
    content_type 'text/plain'
    "ok\n"
  end

  post '/admin/upgrade_apiserver' do
    authorize!('fullstaq-ruby/infra', environment: 'deploy')

    if !system('sudo', 'systemctl', 'restart', 'apiserver-deployer')
      $stderr.puts "Failed to upgrade API server: #{$?}"
    end

    # Restart apiserver after 5 seconds so that 'systemctl' itself
    # gets a chance to run instead of being immediately killed.
    Thread.new do
      $stderr.puts 'Restarting API server in 5 seconds...'
      sleep 5
      if !system('sudo', 'systemctl', 'restart', 'apiserver')
        $stderr.puts "Failed to restart API server: #{$?}"
      end
    end

    "ok\n"
  end

  post '/admin/restart_web_server' do
    authorize!('fullstaq-ruby/server-edition', environment: 'production')

    # Restart web server after 5 seconds so that this request's
    # response can reach the client.
    Thread.new do
      $stderr.puts 'Restarting web server in 5 seconds...'
      sleep 5
      if !system('sudo', 'systemctl', 'restart', 'caddy')
        $stderr.puts "Failed to restart web server: #{$?}"
      end
    end

    "ok\n"
  end

  private

  def authorize!(repository, expected_claim_values = {})
    token = extract_authz_token
    halt 401, 'Missing or invalid Authorization header' unless token

    begin
      decoded_token = verify_github_jwt(token)
      if !valid_claims?(decoded_token[0], repository, expected_claim_values)
        halt 403, 'Invalid authorization token claims'
      end
    rescue JWT::DecodeError => e
      halt 403, "Invalid authorization token: #{e.message}"
    end
  end

  def extract_authz_token
    authz_header = request.env['HTTP_AUTHORIZATION']
    authz_header&.start_with?('Bearer ') ? authz_header.split(' ', 2).last : nil
  end

  def verify_github_jwt(token)
    JWT.decode(token, nil, true, {
      algorithms: ['RS256'],
      jwks: fetch_github_jwks,
      iss: GITHUB_ACTIONS_OIDC_ISSUER_URL,
      verify_iss: true,
      aud: EXPECTED_AUDIENCE_CLAIM,
      verify_aud: true,
      verify_iat: true,
      leeway: 60 # 1 minute leeway for clock skew
    })
  end

  def fetch_github_jwks
    @github_jwks ||= begin
      resp = Net::HTTP.get_response(URI(GITHUB_JWKS_URL))
      halt 500, 'Failed to fetch GitHub JWKS' unless resp.is_a?(Net::HTTPSuccess)
      JSON.parse(resp.body)
    end
  end

  def valid_claims?(claims, repository, expected_claim_values)
    if !claims['sub'].start_with?("repo:#{repository}:") || claims['repository'] != repository
      $stderr.puts "Invalid repository claim: expected=#{repository.inspect}, actual=#{JSON.pretty_generate(claims)}"
      return false
    end

    if claims['runner_environment'] != 'github-hosted'
      $stderr.puts "Invalid runner_environment claim: expected=github-hosted, actual=#{JSON.pretty_generate(claims)}"
      return false
    end

    expected_claim_values.each_pair do |key, value|
      if claims[key.to_s] != value
        $stderr.puts "Invalid #{key} claim: expected=#{value.inspect}, actual=#{JSON.pretty_generate(claims)}"
        return false
      end
    end

    true
  end
end
