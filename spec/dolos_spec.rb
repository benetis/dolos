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


  describe 'map' do
    it 'maps over one parser' do
      parser = string('hello').map_value { |value| value.upcase }
      result = parser.run('hello')

      expect(result.value).to eq('HELLO')
    end

    it 'maps over two parsers' do
      parser = (string('hello') >> string('world')).map_value { |value| value.map(&:upcase) }
      result = parser.run('helloworld')

      expect(result.value).to eq(['HELLO', 'WORLD'])
    end

    it 'maps over two parsers and uses them in a third' do
      loud_hello = (string('hello') >> string('world')).map_value { |value| value.map(&:upcase) }

      parser = loud_hello >> string('!')

      result = parser.run('helloworld!')
      expect(result.value.flatten).to eq(['HELLO', 'WORLD', '!'])
    end

    it 'maps over parsers and converts them to ints' do
      parser = (string("1") >> string("2") >> string("3")).capture!.flatten.map { |value| value.map(&:to_i) }

      result = parser.run("123")
      expect(result.captures).to eq([1, 2, 3])
    end

    it 'maps over groups and converts to ints' do
      first = (string("1") >> string("2")).capture!.map { |value| value.map(&:to_i) }
      second = (string("3") >> string("4")).capture!.map { |value| value.map(&:to_i) }
      parser = (first >> second)

      result = parser.run("1234")
      expect(result.captures).to eq([1, 2, 3, 4])
    end

  end

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
  end

end
