require 'rest-client'
require 'time'
require 'logger'

module Cleverreach

  class Helper

    attr_reader :credentials, :host, :token
    attr_accessor :log, :helper

    def initialize(credentials)
      @host = 'https://rest.cleverreach.com/v2/'
      @credentials = credentials
      @log = Logger.new(STDOUT)
    end

    def login
      response = RestClient.post "#{host}login.json", credentials.to_json, content_type: :json, accept: :json, timeout: 30
      return response.body
    end

    def check(email, group_id)
      raise Cleverreach::Errors::ValidationError, "Invalid email: #{email}" unless Validator.valid_email?(email)

      token = login
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

    def get_forms(group_id)
      token = login
      params = token.delete('"')
      uri = "#{host}groups.json/#{group_id}/forms?token=#{params}"
      begin
        retval = RestClient.get uri, accept: :json, timeout: 15
        log.info(retval.body)
        return JSON.parse(retval)
      rescue RestClient::ExceptionWithResponse => e
        log.info(e.response)
        return false
      end
    end
  end
end
