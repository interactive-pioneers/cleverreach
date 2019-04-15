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

    def get_form_doidata(doi_data)
      raise 'You must provide well configured Cleverreach DOI data' unless doi_data.is_a?(Cleverreach::Doidata)

      begin
        return doi_data.form_id
      rescue
        log.info("DOI Data was not correctly defined")
        return false
      end
    end

    def form_exists?(group_id, form_id)
      forms = get_forms(group_id)

      if forms.length === 1
        form = forms[0]
        actualFormID = get_form_id(form);

        if actualFormID.to_s != form_id.to_s
          log.info("The give form_id does not exist")
          return false
        else
          return true
        end

      elsif forms.length > 1
        checker = false

        for form in forms
          actualFormID = get_form_id(form)
          log.info("#{actualFormID} VS #{form_id}")
          if actualFormID.to_s === form_id.to_s
            checker = true
          end
        end
        return checker

      else
        log.info("No forms found")
        return false
      end

      return false
    end

    def get_first_form_id (group_id)
      forms = get_forms(group_id)
      if(forms.length > 0)
        return get_form_id(forms[0])
      end
      return false
    end

    def get_form_id(form)
      if form.has_key? 'id'
        return form['id']
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
