# frozen_string_literal: true

RSpec.describe Dolos do
  include Dolos
  describe 'run' do

    it 'should match a string and return success' do
      parser = string('hello')
      result = parser.run('hello')

      expect(result.success?).to be_truthy
    end
  end

  describe 'product' do

    it 'should combine two parsers' do
      parser = string('hello') >> string('world')
      result = parser.run('helloworld')

      expect(result.success?).to be_truthy
    end

    it 'should combine three parsers' do
      parser = string('hello') >> string('world') >> string('!')
      result = parser.run('helloworld!')

      expect(result.success?).to be_truthy
    end

    it 'should combine four parsers' do
      parser = string('hello') >> string('world') >> string('!') >> string('!')
      result = parser.run('helloworld!!')

      expect(result.success?).to be_truthy
    end

    it 'should combine five parsers' do
      parser = string('hello') >> string(' ') >> string('world') >> string(',') >> string(' and universe')
      result = parser.run('hello world, and universe')

      expect(result.success?).to be_truthy
    end

  end

end
