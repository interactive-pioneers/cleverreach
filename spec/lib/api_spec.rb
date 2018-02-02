# frozen_string_literal: true

require 'spec_helper'

describe Cleverreach::API, :vcr do
  let(:credentials) { Cleverreach::Credentials.new('123456', 'user', 'pass') }
  let(:doidata) { Cleverreach::Doidata.new('123456', '127.0.0.1', 'localhost', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36') }
  let(:api) { Cleverreach::API.new(credentials) }
  let(:api_with_doidata) { Cleverreach::API.new(credentials, doidata) }

  describe '#initialize' do
    context 'fails' do
      it 'without credentials' do
        expect { Cleverreach::API.new }.to raise_error
      end

      it 'with invalid credentials type' do
        expect { Cleverreach::API.new('credentials') }.to raise_error
      end

      it 'with invalid doidata type' do
        expect { Cleverreach::API.new(credentials, 'doidata') }.to raise_error
      end
    end

    context 'succeeds' do
      it 'with credentials, without doidata' do
        expect(api).to be_an_instance_of Cleverreach::API
      end

      it 'with credentials, with doidata' do
        expect(api_with_doidata).to be_an_instance_of Cleverreach::API
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

        # @TODO test with doidata provided
        # it 'with 200 insert success with doi email' do
        #   expect(api_with_doidata.subscribe('bruce@gotham.com', '654321')).to be_truthy
        # end
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
