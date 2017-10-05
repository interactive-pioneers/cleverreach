# frozen_string_literal: true

module Cleverreach
  class Validator
    def self.valid_email?(email)
      !/\A([A-Z0-9a-z._%+-@]+@[A-Za-z0-9._%+-]+\.[A-Za-z]{2,})\Z/.match(email).nil?
    end
  end
end
