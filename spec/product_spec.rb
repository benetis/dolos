# frozen_string_literal: true

RSpec.describe Dolos do
  include Dolos

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

    context 'when failure' do
      it 'tries to combine two parsers and returns failure' do
        parser = string('hello') >> string('world')
        result = parser.run('helloX')

        expect(result.failure?).to be_truthy
      end

    end

    context 'when returning a value' do
      it 'returns parse value' do
        parser = string('hello') >> string('X')
        result = parser.run('helloX')

        expect(result.value).to eq(['hello', 'X'])
      end
    end

  end

end