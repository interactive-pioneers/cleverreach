# frozen_string_literal: true

require 'pry'
require 'cleverreach'
require 'vcr'
require 'webmock/rspec'
# require 'support/mock_maileon'

# Do not allow external calls to API
WebMock.disable_net_connect!(allow_localhost: true)

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.ignore_localhost = true
  config.configure_rspec_metadata!
end

# Stub all external API calls for WebMock
RSpec.configure do |config|
  config.before(:each) do
    # stub_request(:any, /api.cleverreach.com/).to_rack(MockMaileon)
  end
end
