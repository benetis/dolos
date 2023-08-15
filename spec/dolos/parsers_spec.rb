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

        expect(result.success?).to be_truthy
      end

      it 'parses symbols like ?.@#$%^&*()_+' do
        parser = c('?.@#$%^&*()_+')
        result = parser.run('?.@#$%^&*()_+')

        expect(result.success?).to be_truthy
      end

    end

  end

  describe 'regex' do
    context 'when digits' do
      it 'parses digits' do
        parser = regex(/\d+/)
        result = parser.run('123')

        expect(result.success?).to be_truthy
        expect(result.value).to eq('123')
      end

      it 'only parses digits' do
        parser = regex(/\d+/)
        result = parser.run('123abc')

        expect(result.success?).to be_truthy
        expect(result.value).to eq('123')
      end
    end

    context 'product' do
      it 'parses two regexes' do
        digits = regex(/\d+/)
        letters = regex(/[a-z]+/)
        parser = digits >> letters
        result = parser.run('123abc')

        expect(result.success?).to be_truthy
        expect(result.value).to eq(['123', 'abc'])
      end

      it 'parses three regexes' do
        digits = regex(/\d+/)
        letters = regex(/[a-z]+/)
        parser = letters >> digits >> letters
        result = parser.run('a123abchello')

        expect(result.success?).to be_truthy
        expect(result.value).to eq([["a", "123"], "abchello"])
      end

      it 'parses a regex and a string' do
        digits = regex(/\d+/)
        hello = c('hello')

        parser = digits >> hello
        result = parser.run('123hello')

        expect(result.success?).to be_truthy
        expect(result.value).to eq(['123', 'hello'])
      end

      it 'parses a string and a regex' do
        digits = regex(/\d+/)
        hello = c('hello')

        parser = hello >> digits
        result = parser.run('hello123')

        expect(result.success?).to be_truthy
        expect(result.value).to eq(['hello', '123'])
      end

      it 'fails because regex consumes all the letters' do
        digits = regex(/\d+/)
        letters = regex(/[a-z]+/)
        parser = letters >> digits >> letters >> c("missing")
        result = parser.run('a123abchellomissing')

        expect(result.failure?).to be_truthy
      end

    end
  end



end
