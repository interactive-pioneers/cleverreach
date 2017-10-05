# frozen_string_literal: true

require 'spec_helper'

describe Cleverreach::API do
  describe '#initialize' do
    context 'fails' do
      it 'without credentials' do
        expect { Cleverreach::API.new }.to raise_error
      end

      it 'with invalid credentials type' do
        expect { Cleverreach::API.new('credentials') }.to raise_error
      end
    end

    context 'succeeds' do
      it 'with credentials' do
        credentials = Cleverreach::Credentials.new('123456', 'username', 'password')
        actual = Cleverreach::API.new(credentials)
        expect(actual).to be_an_instance_of Cleverreach::API
      end
    end
  end
end
