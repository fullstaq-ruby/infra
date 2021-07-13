# frozen_string_literal: true

require 'time'
require 'sinatra/base'
require 'rack/auth/basic'
require_relative 'constants'
require_relative 'sse_writer'
require_relative 'keep_aliver'
require_relative 'utils'

class App < Sinatra::Base
  def initialize(*args, utils: Utils.new)
    super(*args)
    @utils = utils
  end

  configure do
    # Let middlewares handle exceptions
    set :dump_errors, false
  end

  helpers do
    def stream_sse
      content_type 'text/event-stream'

      stream do |out|
        @utils.uncork_socket(request.env)
        writer = SSEWriter.new(out)
        begin
          KeepAliver.run(writer) do
            yield writer
          end
        rescue => e
          writer.write(
            data: "Unexpected error: #{e}",
            type: :error
          )
          Google::Cloud::ErrorReporting.report(e)
          raise e
        end
      end
    end
  end

  get '/' do
    content_type 'text/plain'
    "ok\n"
  end

  post '/actions/reload_web_server' do
    stream_sse(&lambda do |writer|
      writer.write(
        data: 'Logging into Kubernetes',
        type: :status
      )
      err = @utils.run_command('gcloud', 'container', 'clusters', 'get-credentials',
        "--project=#{GCLOUD_PROJECT}",
        "--region=#{KUBERNETES_CLUSTER_REGION}",
        KUBERNETES_CLUSTER_NAME)
      if err
        writer.write(
          data: "Error getting Kubernetes cluster credentials: #{err}",
          type: :error
        )
        return
      end

      writer.write(
        data: 'Initating web server restart',
        type: :status
      )
      err = @utils.run_command('kubectl', 'rollout', 'restart',
        "--namespace=#{KUBERNETES_NAMESPACE}",
        'deploy/gateway')
      if err
        writer.write(
          data: "Error initiating web server restart: #{err}",
          type: :error
        )
        return
      end

      writer.write(
        data: 'Waiting for web server restart to finish',
        type: :status
      )
      command = ['kubectl', 'rollout', 'status',
        "--timeout=#{WEB_SERVER_RESTART_TIMEOUT}",
        "--namespace=#{KUBERNETES_NAMESPACE}",
        'deploy/gateway']
      ok = @utils.run_command_stream_output(*command) do |line|
        writer.write(
          data: line.chomp,
          type: :status
        )
      end
      if !ok
        writer.write(
          data: 'Error restarting web server',
          type: :error
        )
        return
      end

      writer.write(data: 'success', type: :success)
    end)
  end
end
