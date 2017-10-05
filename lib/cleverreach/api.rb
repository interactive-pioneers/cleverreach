# frozen_string_literal: true

require 'rest-client'

module Cleverreach
  class API
    attr_reader :credentials, :host, :token

    def initialize(credentials)
      @host = 'https://rest.cleverreach.com/v2/'

      raise 'You must provide Cleverreach credentials' unless credentials && credentials.is_a?(Cleverreach::Credentials)
      @credentials = credentials
    end

    def login
      response = RestClient.post "#{host}login.json", credentials.to_json, content_type: :json, accept: :json
      @token = response.body
    end
  end
end
