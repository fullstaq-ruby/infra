# frozen_string_literal: true

require "json"
require "openssl"

require_relative "spec_helper"

RSpec.describe App do
  let(:app) { described_class.new }
  let(:request) { Rack::MockRequest.new(app) }

  let(:private_key) { OpenSSL::PKey::RSA.generate(2048) }
  let(:jwks) do
    {
      "keys" => [
        JWT::JWK.new(private_key.public_key, kid: "spec-kid").export,
      ],
    }
  end

  def auth_header_for(payload)
    token = JWT.encode(payload, private_key, "RS256", { kid: "spec-kid" })
    { "HTTP_AUTHORIZATION" => "Bearer #{token}" }
  end

  describe "GET /" do
    before do
      allow_any_instance_of(App).to receive(:log_info)
      allow_any_instance_of(App).to receive(:log_error)
    end

    it "returns ok" do
      response = request.get("/")

      expect(response.status).to eq(200)
      expect(response.body).to eq("ok\n")
    end
  end

  describe "POST /admin/restart_web_server" do
    let(:now) { Time.now.to_i }
    let(:base_payload) do
      {
        "iss" => App::GITHUB_ACTIONS_OIDC_ISSUER_URL,
        "aud" => App::EXPECTED_AUDIENCE_CLAIM,
        "iat" => now,
        "repository" => "fullstaq-ruby/server-edition",
        "sub" => "repo:fullstaq-ruby/server-edition:ref:refs/heads/main",
        "runner_environment" => "github-hosted",
        "environment" => "deploy",
      }
    end

    before do
      allow_any_instance_of(App).to receive(:fetch_github_jwks).and_return(jwks)
      allow_any_instance_of(App).to receive(:sleep)
      allow_any_instance_of(App).to receive(:log_info)
      allow_any_instance_of(App).to receive(:log_error)
    end

    it "returns 401 when Authorization header is missing" do
      expect_any_instance_of(App).not_to receive(:log_error)
      expect_any_instance_of(App).not_to receive(:log_info)
      response = request.post("/admin/restart_web_server")

      expect(response.status).to eq(401)
      expect(response.body).to include("Missing or invalid Authorization header")
    end

    it "restarts caddy when token claims are valid" do
      commands = []
      expect_any_instance_of(App).to receive(:system) do |_instance, *args|
        commands << args
        true
      end
      expect_any_instance_of(App).to receive(:new_thread) do |&block|
        block.call
        double("thread")
      end
      expect_any_instance_of(App).to receive(:log_info).with(/Restarting web server in 5 seconds/)

      response = request.post("/admin/restart_web_server", auth_header_for(base_payload))

      expect(response.status).to eq(200)
      expect(response.body).to eq("ok\n")
      expect(commands).to include(["sudo", "systemctl", "restart", "caddy"])
    end

    it "returns 403 when claims are invalid" do
      expect_any_instance_of(App).to receive(:log_error).with(/Invalid runner_environment claim/)
      payload = base_payload.merge("runner_environment" => "self-hosted")

      response = request.post("/admin/restart_web_server", auth_header_for(payload))

      expect(response.status).to eq(403)
      expect(response.body).to include("Invalid authorization token claims")
    end

    it "returns 403 when signature is invalid" do
      wrong_key = OpenSSL::PKey::RSA.generate(2048)
      token = JWT.encode(base_payload, wrong_key, "RS256", { kid: "spec-kid" })

      response = request.post("/admin/restart_web_server", {
        "HTTP_AUTHORIZATION" => "Bearer #{token}",
      })

      expect(response.status).to eq(403)
      expect(response.body).to include("Invalid authorization token")
    end
  end

  describe "POST /admin/upgrade_apiserver" do
    let(:now) { Time.now.to_i }
    let(:payload) do
      {
        "iss" => App::GITHUB_ACTIONS_OIDC_ISSUER_URL,
        "aud" => App::EXPECTED_AUDIENCE_CLAIM,
        "iat" => now,
        "repository" => "fullstaq-ruby/infra",
        "sub" => "repo:fullstaq-ruby/infra:ref:refs/heads/main",
        "runner_environment" => "github-hosted",
        "environment" => "deploy",
      }
    end

    before do
      allow_any_instance_of(App).to receive(:fetch_github_jwks).and_return(jwks)
      allow_any_instance_of(App).to receive(:sleep)
      allow_any_instance_of(App).to receive(:log_info)
      allow_any_instance_of(App).to receive(:log_error)
    end

    it "restarts deployer immediately and apiserver asynchronously" do
      commands = []
      expect_any_instance_of(App).to receive(:system).exactly(2).times do |_instance, *args|
        commands << args
        true
      end
      expect_any_instance_of(App).to receive(:new_thread) do |&block|
        block.call
        double("thread")
      end

      expect_any_instance_of(App).to receive(:log_info).with(/Restarting API server in 5 seconds/)
      expect_any_instance_of(App).not_to receive(:log_error)

      response = request.post("/admin/upgrade_apiserver", auth_header_for(payload))

      expect(response.status).to eq(200)
      expect(response.body).to eq("ok\n")
      expect(commands).to include(["sudo", "systemctl", "restart", "apiserver-deployer"])
      expect(commands).to include(["sudo", "systemctl", "restart", "apiserver"])
    end
  end

  describe "JWKS I/O failures" do
    before do
      allow_any_instance_of(App).to receive(:log_info)
      allow_any_instance_of(App).to receive(:log_error)
    end

    it "returns 500 when JWKS cannot be fetched" do
      failing_response = Object.new
      def failing_response.is_a?(klass)
        return false if klass == Net::HTTPSuccess

        super
      end

      expect(Net::HTTP).to receive(:get_response).and_return(failing_response)
      expect_any_instance_of(App).not_to receive(:log_error)
      expect_any_instance_of(App).not_to receive(:log_info)

      response = request.post("/admin/restart_web_server", {
        "HTTP_AUTHORIZATION" => "Bearer dummy",
      })

      expect(response.status).to eq(500)
      expect(response.body).to include("Failed to fetch GitHub JWKS")
    end
  end
end
