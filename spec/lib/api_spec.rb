# frozen_string_literal: true

require 'spec_helper'

describe Cleverreach::API, :vcr do
  let(:credentials) { Cleverreach::Credentials.new('123456', 'user', 'pass') }
  let(:api) { Cleverreach::API.new(credentials) }

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
        expect(api).to be_an_instance_of Cleverreach::API
      end
    end
  end

  describe '#login' do
    VCR.use_cassette('login') do
      context 'fails' do
        it 'with 400 response' do
          expect { api.login }.to raise_error RestClient::ExceptionWithResponse
        end
      end

      context 'succeeds' do
        it 'with auth token response' do
          api.login
          expect(api.token).to eq('"ey123"')
        end
      end
    end
  end

  describe '#subscribe' do
    VCR.use_cassette('subscribe') do
      context 'fails' do
        it 'with exception for invalid email' do
          allow(Cleverreach::Validator).to receive(:valid_email?).and_return(false)
          expect { api.subscribe('email@domain.de', '654322') }.to raise_error Cleverreach::Errors::ValidationError
        end

        it 'with 405 response for invalid group' do
          expect { api.subscribe('email@domain.de', '654322') }.to raise_error RestClient::ExceptionWithResponse
        end
      end

      context 'succeeds' do
        it 'with 200 insert success' do
          expect(api.subscribe('bruce@gotham.com', '654321')).to be_truthy
        end

        it 'with 200 insert success including source' do
          expect(api.subscribe('bruce@gotham.de', '654321', 'rspec')).to be_truthy
        end

        it 'with 200 insert success including body' do
          body = { 'firstname' =>  'Firstname', 'lastname' => 'Lastname'}
          expect(api.subscribe('bruce@gotham.de', '654321', nil, body)).to be_truthy
        end
      end
    end
  end

  describe '#unsubscribe' do
    VCR.use_cassette('unsubscribe') do
      context 'fails' do
        it 'with exception for invalid email' do
          allow(Cleverreach::Validator).to receive(:valid_email?).and_return(false)
          expect { api.unsubscribe('email@domain.de', '654322') }.to raise_error Cleverreach::Errors::ValidationError
        end

        it 'with 404 response' do
          expect { api.unsubscribe('email@domain.de', '654321') }.to raise_error RestClient::ExceptionWithResponse
        end
      end

      context 'succeeds' do
        it 'with 200 response' do
          expect(api.unsubscribe('bruce@gotham.com', '654321')).to be_truthy
        end
      end
    end
  end
end
