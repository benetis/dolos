# frozen_string_literal: true

RSpec.describe Dolos do
  include Dolos
  describe 'run' do

    it 'should match a string and return success' do
      parser = string('hello')
      result = parser.run('hello')

      expect(result.success?).to be_truthy
      expect(result.value).to eq('hello')
    end
  end

  describe 'associativity' do
    context '>>' do
      it 'is left associative' do
        parser = string('hello') >> string('world') >> string('!')
        result = parser.run('helloworld!')

        expect(result.success?).to be_truthy
      end

      it 'is right associative' do
        parser = string('hello') >> (string('world') >> string('!'))
        result = parser.run('helloworld!')

        expect(result.success?).to be_truthy
      end
    end

    context '|' do
      it 'is left associative' do
        parser = string('hello') | string('world') | string('!')
        result = parser.run('helloworld!')

        expect(result.success?).to be_truthy
        expect(result.value).to eq('hello')
      end
    end

  end

end
