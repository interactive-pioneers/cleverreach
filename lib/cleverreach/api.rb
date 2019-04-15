# frozen_string_literal: true

require 'rest-client'
require 'time'
require 'logger'

module Cleverreach
  class API
    attr_reader :credentials, :host, :token, :doidata
    attr_accessor :log, :helper

    def initialize(credentials, doidata = nil)
      @host = 'https://rest.cleverreach.com/v2/'
      @log = Logger.new(STDOUT)

      raise 'You must provide Cleverreach credentials' unless credentials && credentials.is_a?(Cleverreach::Credentials)

      @helper = Helper.new(credentials)

      raise 'You must provide well configured Cleverreach DOI data or nil for SOI' unless doidata.nil? || doidata.is_a?(Cleverreach::Doidata)

      @doidata = doidata
    end

    def subscribe(email, group_id, source = '', body = {})
      raise Cleverreach::Errors::ValidationError, "Invalid email: #{email}" unless Validator.valid_email?(email)

      token = helper.login
      body = body_data(email, source, body)
      params = "?token=#{token.delete('"')}"
      uri = "#{host}groups.json/#{group_id}/receivers/insert#{params}"

      given_form_id = helper.get_form_doidata(@doidata)

      if helper.form_exists?(group_id, given_form_id) === false
        @doidata.change_form(helper.get_first_form_id(group_id))
      end
      log.info(@doidata)

      if helper.check(email, group_id)
        RestClient.post(uri, body.to_json, content_type: :json, accept: :json, timeout: 1)
        send_doi_email(email, group_id) unless @doidata.nil?
      end
    end

    def unsubscribe(email, group_id)
      raise Cleverreach::Errors::ValidationError, "Invalid email: #{email}" unless Validator.valid_email?(email)

      token = helper.login
      email = CGI.escape(email)
      params = "?token=#{token.delete('"')}"
      url = "#{host}groups.json/#{group_id}/receivers/#{email}#{params}"
      RestClient.delete url, content_type: :json, accept: :json, timeout: 15
    end

    private

    def send_doi_email(email, group_id)
      token = Helper.login
      params = "?token=#{token.delete('"')}"
      uri = "#{host}forms.json/#{@doidata.doi_form_id}/send/activate#{params}"
      body = @doidata.doi_data.merge(
        'email' => email,
        'groups_id' => group_id
      )
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

