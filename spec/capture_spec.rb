# frozen_string_literal: true

RSpec.describe Dolos do
  include Dolos

  describe 'capture' do
    it 'captures the result of a parser' do
      parser = string('hello').capture!
      result = parser.run('hello')

      expect(result.captures).to eq(['hello'])
    end

    it 'captures the result of two parsers' do
      parser = (string('hello') >> string('world')).capture!
      result = parser.run('helloworld')

      expect(result.captures).to eq(['hello', 'world'])
    end

    it 'captures the result of two parsers but not third' do
      loud_hello = (string('hello') >> string('world')).capture!

      parser = loud_hello >> string('!') >> string('!')

      result = parser.run('helloworld!!')
      expect(result.captures).to eq(['hello', 'world'])
    end

    it 'captures result of parser and maps over it' do
      parser = string('hello').capture!.map { |value| value.map(&:upcase) }
      result = parser.run('hello')

      expect(result.captures).to eq(['HELLO'])
    end

    it 'captures result of two parsers and maps over them' do
      parser = (string('hello') >> string('world')).capture!.map { |value| value.map(&:upcase) }
      result = parser.run('helloworld')

      expect(result.captures).to eq(['HELLO', 'WORLD'])
    end

    context 'when failure' do
      it 'captures the result of a parser' do
        parser = string('hello').capture!
        result = parser.run('Xhello')

        expect(result.failure?).to be_truthy
        expect(result.captures).to eq([])
      end

      it 'captures the result of two parsers' do
        parser = (string('hello') >> string('world')).capture!
        result = parser.run('Xhelloworld')

        expect(result.failure?).to be_truthy
        expect(result.captures).to eq([])
      end

    end

    context 'when wrap_in is defined' do
      it 'should wrap capture in array' do
        parser = string('hello').capture!([])
        result = parser.run('hello')

        expect(result.captures).to eq(['hello'])
      end

      it 'should wrap capture in hash' do
        parser = string('hello').capture!(:hallo)
        result = parser.run('hello')

        expect(result.captures).to eq([{:hallo => 'hello'}])
      end
    end
  end

end