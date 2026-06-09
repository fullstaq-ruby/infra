require "sinatra/base"

class FixtureApp < Sinatra::Base
  get "/admin/health" do
    "ok"
  end
end

run FixtureApp
