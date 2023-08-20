# frozen_string_literal: true
require 'dolos_common_parsers/common_parsers'

RSpec.describe Dolos::CommonParsers do
  include Dolos
  include Dolos::CommonParsers

  describe 'ws' do
    it 'parses whitespace' do
      parser = ws
      result = parser.run(' ')

      expect(result.success?).to be_truthy
    end
  end

  describe 'ws_rep0' do
    it 'parses one or more whitespace' do
      parser = ws_rep0
      result = parser.run('   ')

      expect(result.success?).to be_truthy
    end

    it 'parses zero whitespace' do
      parser = ws_rep0
      result = parser.run('')

      expect(result.success?).to be_truthy
    end
  end

  describe 'int' do
    it 'converts to integer' do
      parser = int.capture!
      result = parser.run('1')

      expect(result.success?).to be_truthy
      expect(result.captures).to eq([1])
    end
  end

  describe 'digits' do
    it 'parses digits' do
      parser = digits
      result = parser.run('123')

      expect(result.success?).to be_truthy
      expect(result.value).to eq('123')
    end
  end

  describe 'alpha_num' do
    it 'parses a letter' do
      parser = alpha_num
      result = parser.run('a')

      expect(result.success?).to be_truthy
      expect(result.value).to eq('a')
    end

    it 'parses a digit' do
      parser = alpha_num
      result = parser.run('1')

      expect(result.success?).to be_truthy
      expect(result.value).to eq('1')
    end
  end

end
