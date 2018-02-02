# frozen_string_literal: true

require 'spec_helper'

describe Cleverreach::Doidata do

  let(:form_id) { '123456' }
  let(:ip) { '127.0.0.1' }
  let(:referer) { 'localhost' }
  let(:user_agent) { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36' }

  describe '#initialize' do
    context 'fails' do
      it 'when missing form_id' do
        expect { Cleverreach::Doidata.new(nil, ip, referer, user_agent) }.to raise_error
      end

      it 'when missing ip' do
        expect { Cleverreach::Doidata.new(form_id, nil, referer, user_agent) }.to raise_error
      end

      it 'when missing referer' do
        expect { Cleverreach::Doidata.new(form_id, ip, nil, user_agent) }.to raise_error
      end

      it 'when missing user_agent' do
        expect { Cleverreach::Doidata.new(form_id, ip, referer, nil) }.to raise_error
      end
    end

    context 'succeeds' do
      it 'with complete credentials' do
        doidata = Cleverreach::Doidata.new(form_id, ip, referer, user_agent)
        expect(doidata).to be_an_instance_of Cleverreach::Doidata
      end

      it 'with environment-based doidata' do
        ENV['CLEVERREACH_FORM_ID'] = form_id
        ENV['CLEVERREACH_DOI_IP'] = ip
        ENV['CLEVERREACH_DOI_REFERER'] = referer
        ENV['CLEVERREACH_DOI_USERAGENT'] = user_agent
        doidata = Cleverreach::Doidata.new
        expect(doidata).to be_an_instance_of Cleverreach::Doidata
      end
    end
  end

  describe '#doi_form_id' do
    it '' do
      doidata = Cleverreach::Doidata.new(form_id, ip, referer, user_agent)
      expect(doidata.doi_form_id).to eq('123456')
    end
  end

  describe '#doi_data' do
    it '' do
      doidata = Cleverreach::Doidata.new(form_id, ip, referer, user_agent)
      expect(doidata.doi_data).to eq({
        'doidata' => {
          'user_ip' => '127.0.0.1',
          'referer' => 'localhost',
          'user_agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36',
        }
      })
    end
  end

end
