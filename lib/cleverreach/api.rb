# frozen_string_literal: true

require 'rest-client'

module Cleverreach
  class API
    attr_reader :credentials, :host, :token, :doidata

    def initialize(credentials, doidata = nil)
      @host = 'https://rest.cleverreach.com/v2/'

      raise 'You must provide Cleverreach credentials' unless credentials && credentials.is_a?(Cleverreach::Credentials)
      @credentials = credentials

      raise 'You must provide well configured Cleverreach DOI data or nil for SOI' unless doidata.nil? || doidata.is_a?(Cleverreach::Doidata)
      @doidata = doidata
    end

    def login
      response = RestClient.post "#{host}login.json", credentials.to_json, content_type: :json, accept: :json
      @token = response.body
    end

    def subscribe(email, group_id, source = '', body = {})
      raise Cleverreach::Errors::ValidationError, "Invalid email: #{email}" unless Validator.valid_email?(email)

      login
      
      body = body_data(email, source, body)
      params = "?token=#{token.delete('"')}"
      uri = "#{host}groups.json/#{group_id}/receivers/insert#{params}"
      
      if @doidata.nil?
        RestClient.post uri, body.to_json, content_type: :json, accept: :json
      else
        RestClient.post uri, body.to_json, content_type: :json, accept: :json
        send_doi_email(email, group_id)
      end
    end

    def unsubscribe(email, group_id)
      raise Cleverreach::Errors::ValidationError, "Invalid email: #{email}" unless Validator.valid_email?(email)

      login
      email = CGI.escape(email)
      params = "?token=#{token.delete('"')}"
      RestClient.delete "#{host}groups.json/#{group_id}/receivers/#{email}#{params}", content_type: :json, accept: :json
    end

    private

    def send_doi_email(email, group_id)
      params = "?token=#{token.delete('"')}"
      uri = "#{host}forms.json/#{@doidata.doi_form_id}/send/activate#{params}"
      body = @doidata.doi_data.merge({
        'email' => email,
        'groups_id' => group_id
      })

      begin
        res = RestClient.post uri, body.to_json, content_type: :json, accept: :json
      rescue => error
        abort res.inspect
      end
    end

    def body_data(email, source, body)
      {
        'postdata' => [
          {
            'email' => email,
            'registered' => DateTime.now.to_formatted_s(:number),
            'activated' => @doidata.nil?,
            'source' => source,
            "global_attributes": body,
          }
        ]
      }
    end
  end
end
