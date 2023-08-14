# frozen_string_literal: true

require 'rspec'

RSpec.describe Dolos::Parsers do
  include Dolos
  describe 'string' do

    context 'when basic case' do
      it 'parses a string' do
        parser = string('hello')
        result = parser.run('hello')

        expect(result.success?).to be_truthy
      end

      it 'parses a string with alias' do
        parser = c('hello')
        result = parser.run('hello')

        expect(result.success?).to be_truthy
      end
    end

    context 'when special letters' do
      it 'parses a string with šįėę and etc.' do
        parser = c('šįėę')
        result = parser.run('šįėę')

        pp result.inspect

        expect(result.success?).to be_truthy
      end

      it 'parses symbols like ?.@#$%^&*()_+' do
        parser = c('?.@#$%^&*()_+')
        result = parser.run('?.@#$%^&*()_+')

        pp result.inspect

        expect(result.success?).to be_truthy
      end

    end

  end


end
