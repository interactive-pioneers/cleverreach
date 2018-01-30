# frozen_string_literal: true

module Cleverreach
  class Doidata
    attr_reader :form_id, :ip, :referer, :user_agent

    def initialize(form_id = nil, ip = nil, referer = nil, user_agent = nil)
      form_id ||= ENV['CLEVERREACH_FORM_ID']
      ip ||= ENV['CLEVERREACH_DOI_IP']
      referer ||= ENV['CLEVERREACH_DOI_REFERER']
      user_agent ||= ENV['CLEVERREACH_DOI_USERAGENT']

      raise 'You must provide a Cleverreach formId, ip, referer and an user_agent' unless form_id && ip && referer && user_agent

      @form_id = form_id
      @ip = ip
      @referer = referer
      @user_agent = user_agent
    end

    def doi_form_id
      @form_id
    end

    def doi_data
      {
        'doidata' => {
          'user_ip' => @ip,
          'referer' => @referer,
          'user_agent' => @user_agent,
        }
      }
    end
  end
end
