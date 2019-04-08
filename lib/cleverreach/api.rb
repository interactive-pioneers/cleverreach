# frozen_string_literal: true

require 'rest-client'
require 'time'
require 'logger'

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
      response = RestClient.post "#{host}login.json", credentials.to_json, content_type: :json, accept: :json, timeout: 30
      @token = response.body
    end

    def subscribe(email, group_id, source = '', body = {})
      raise Cleverreach::Errors::ValidationError, "Invalid email: #{email}" unless Validator.valid_email?(email)

      login

      body = body_data(email, source, body)
      params = "?token=#{token.delete('"')}"
      uri = "#{host}groups.json/#{group_id}/receivers/insert#{params}"

      if check(email, group_id)
        log.info(RestClient.post uri, body.to_json, content_type: :json, accept: :json, timeout: 1)
        send_doi_email(email, group_id) unless @doidata.nil?
      end
    end

    def check(email, group_id)
      raise Cleverreach::Errors::ValidationError, "Invalid email: #{email}" unless Validator.valid_email?(email)

      login

      params = token.delete('"')
      uri = "#{host}receivers.json/#{email}?group_id=#{group_id}&token=#{params}"

      begin
        RestClient.get uri, accept: :json, timeout: 15
      rescue RestClient::ExceptionWithResponse => e
        log.info(e.response)
        return true
      end
      return false

    end

    def unsubscribe(email, group_id)
      raise Cleverreach::Errors::ValidationError, "Invalid email: #{email}" unless Validator.valid_email?(email)

      login
      email = CGI.escape(email)
      params = "?token=#{token.delete('"')}"
      RestClient.delete "#{host}groups.json/#{group_id}/receivers/#{email}#{params}", content_type: :json, accept: :json, timeout: 15
    end

    private

    def send_doi_email(email, group_id)
      params = "?token=#{token.delete('"')}"
      uri = "#{host}forms.json/#{@doidata.doi_form_id}/send/activate#{params}"
      body = @doidata.doi_data.merge(
          'email' => email,
          'groups_id' => group_id
      )
      log = Logger.new(STDOUT)
      log.info(body.to_json)

      begin
        RestClient.post uri, body.to_json, content_type: :json, accept: :json, timeout: 10
      rescue RestClient::ExceptionWithResponse => e
        log.info(e.response)
        return false
      end

      return true
    end

    def body_data(email, source, body)
      {
          'postdata' => [
              {
                  'email' => email,
                  'registered' => Time.now.to_i,
                  'activated' => @doidata.nil?,
                  'source' => source,
                  "global_attributes": body
              }
          ]
      }
    end
  end
end

