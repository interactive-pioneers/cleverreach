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
      login
      body = {
        'postdata' => [
          {
            'email' => email,
            'source' => source
          }
        ]
      }
      uri = "#{host}groups.json/#{group_id}/receivers/insert?token=#{token.delete('"')}"
      RestClient.post uri, body.to_json, content_type: :json, accept: :json
    end

    def unsubscribe(email, group_id)
      login
      email = CGI.escape(email)
      params = "?token=#{token.delete('"')}"
      RestClient.delete "#{host}groups.json/#{group_id}/receivers/#{email}#{params}", content_type: :json, accept: :json
    end
  end
end
