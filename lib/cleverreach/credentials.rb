# frozen_string_literal: true

module Cleverreach
  class Credentials
    attr_reader :client_id, :username, :password

    def initialize(client_id = nil, username = nil, password = nil)
      client_id ||= ENV['CLEVERREACH_CLIENT_ID']
      username ||= ENV['CLEVERREACH_USERNAME']
      password ||= ENV['CLEVERREACH_PASSWORD']

      raise 'You must provide a Cleverreach clientId, username and password' unless client_id && username && password

      @client_id = client_id
      @username = username
      @password = password
    end

    def to_json
      {
        client_id: client_id,
        login: username,
        password: password
      }.to_json
    end
  end
end
