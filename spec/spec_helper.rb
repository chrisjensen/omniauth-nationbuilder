$:.unshift File.dirname(__FILE__) + '/../lib'

require 'rspec'
require 'rack/test'
require 'webmock/rspec'

RSpec.configure do |config|
  config.include WebMock::API
  config.include Rack::Test::Methods
end