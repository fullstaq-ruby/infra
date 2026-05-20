# frozen_string_literal: true

require "rack/mock"
require "rspec"

require_relative "../app"

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.expect_with(:rspec) do |c|
    c.syntax = :expect
  end
end
