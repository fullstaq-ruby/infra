require 'google/cloud/error_reporting'
require './app'
require './utils'

Google::Cloud.configure do |config|
  config.use_error_reporting = ENV['RACK_ENV'] == 'production'
end

utils = Utils.new
use Google::Cloud::ErrorReporting::Middleware
run App.new(utils: utils)
