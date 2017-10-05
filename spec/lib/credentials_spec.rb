# frozen_string_literal: true

require 'spec_helper'

describe Cleverreach::Credentials do
  describe '#initialize' do
    context 'fails' do
      it 'when missing client_id' do
        expect { Cleverreach::Credentials.new(nil, 'username', 'password') }.to raise_error
      end

      it 'when missing username' do
        expect { Cleverreach::Credentials.new('123456', nil, 'password') }.to raise_error
      end

      it 'when missing password' do
        expect { Cleverreach::Credentials.new('123456', 'username', nil) }.to raise_error
      end
    end

    context 'succeeds' do
      it 'with complete credentials' do
        credentials = Cleverreach::Credentials.new('123456', 'username', 'password')
        expect(credentials).to be_an_instance_of Cleverreach::Credentials
      end

      it 'with environment-based credentials' do
        ENV['CLEVERREACH_CLIENT_ID'] = '123456'
        ENV['CLEVERREACH_USERNAME'] = 'username'
        ENV['CLEVERREACH_PASSWORD'] = 'password'
        credentials = Cleverreach::Credentials.new
        expect(credentials).to be_an_instance_of Cleverreach::Credentials
      end
    end
  end
end
