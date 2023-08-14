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

    context 'when success' do
      it 'combines two parsers' do
        parser = string('hello') >> string('world')
        result = parser.run('helloworld')

        expect(result.success?).to be_truthy
      end

      it 'combines three parsers' do
        parser = string('hello') >> string('world') >> string('!')
        result = parser.run('helloworld!')

        expect(result.success?).to be_truthy
      end

      it 'combines four parsers' do
        parser = string('hello') >> string('world') >> string('!') >> string('!')
        result = parser.run('helloworld!!')

        expect(result.success?).to be_truthy
      end

      it 'combines five parsers' do
        parser = string('hello') >> string(' ') >> string('world') >> string(',') >> string(' and universe')
        result = parser.run('hello world, and universe')

        expect(result.success?).to be_truthy
      end
    end

  end

end
