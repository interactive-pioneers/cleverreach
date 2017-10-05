# frozen_string_literal: true

module Cleverreach
  class API
    def initialize(credentials = nil)
      raise 'You must provide Cleverreach credentials' unless credentials && credentials.is_a?(Cleverreach::Credentials)
    end
  end
end
