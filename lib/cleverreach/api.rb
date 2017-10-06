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

    def subscribe(email, group_id, source = '')
      raise Cleverreach::Errors::ValidationError, "Invalid email: #{email}" unless Validator.valid_email?(email)

      login
      body = body_data(email, source)
      params = "?token=#{token.delete('"')}"
      uri = "#{host}groups.json/#{group_id}/receivers/insert#{params}"
      RestClient.post uri, body.to_json, content_type: :json, accept: :json
    end

    def unsubscribe(email, group_id)
      raise Cleverreach::Errors::ValidationError, "Invalid email: #{email}" unless Validator.valid_email?(email)

      login
      email = CGI.escape(email)
      params = "?token=#{token.delete('"')}"
      RestClient.delete "#{host}groups.json/#{group_id}/receivers/#{email}#{params}", content_type: :json, accept: :json
    end

    private

    def body_data(email, source)
      {
        'postdata' => [
          {
            'email' => email,
            'source' => source
          }
        ]
      }
    end
  end
end
