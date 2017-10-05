# frozen_string_literal: true

require 'spec_helper'

describe Cleverreach::API, :vcr do
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

  describe '#login' do
    VCR.use_cassette('login') do
      context 'fails' do
        it 'with 400 response' do
          credentials = Cleverreach::Credentials.new('123456', 'username', 'password')
          api = Cleverreach::API.new(credentials)
          expect { api.login }.to raise_error RestClient::ExceptionWithResponse
        end
      end

      context 'succeeds' do
        it 'with auth token response' do
          credentials = Cleverreach::Credentials.new('123456', 'user', 'pass')
          api = Cleverreach::API.new(credentials)
          api.login
          expect(api.token).to eq('"ey123"')
        end
      end
    end
  end

  describe '#unsubscribe' do
    VCR.use_cassette('unsubscribe') do
      context 'fails' do
        it 'with 404 response' do
          credentials = Cleverreach::Credentials.new('123456', 'user', 'pass')
          api = Cleverreach::API.new(credentials)
          expect { api.unsubscribe('email@domain.de', '654321') }.to raise_error RestClient::ExceptionWithResponse
        end
      end

      context 'succeeds' do
        it 'with auth token response' do
          credentials = Cleverreach::Credentials.new('123456', 'user', 'pass')
          api = Cleverreach::API.new(credentials)
          expect(api.unsubscribe('bruce@gotham.com', '654321')).to be_truthy
        end
      end
    end
  end
end
