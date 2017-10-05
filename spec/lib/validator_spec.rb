# frozen_string_literal: true

require 'spec_helper'

describe Cleverreach::Validator do
  describe '#valid_email?' do
    context 'fails' do
      it 'when missing tld' do
        expect(Cleverreach::Validator.valid_email?('name@domain')).to be_falsey
      end

      it 'when missing domain' do
        expect(Cleverreach::Validator.valid_email?('name@.tld')).to be_falsey
      end

      it 'when missing name' do
        expect(Cleverreach::Validator.valid_email?('@domain.tld')).to be_falsey
      end
    end

    context 'succeeds' do
      it 'with simple email' do
        expect(Cleverreach::Validator.valid_email?('name@domain.tld')).to be_truthy
      end

      it 'with special chars' do
        expect(Cleverreach::Validator.valid_email?('na%m+e-@do%m-+ain.tld')).to be_truthy
      end

      it 'with multiple @' do
        expect(Cleverreach::Validator.valid_email?('name@name@domain.tld')).to be_truthy
      end

      it 'with subdomain' do
        expect(Cleverreach::Validator.valid_email?('name@name@sub.domain.tld')).to be_truthy
      end
    end
  end
end
