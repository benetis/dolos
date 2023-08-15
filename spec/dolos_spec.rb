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

    it 'maps over groups to add and then multiply' do
      first = (string("1") >> string("2")).capture!.map { |digit| digit.map(&:to_i).reduce(:+) } # 3
      second = (string("3") >> string("4")).capture!.map { |digit| digit.map(&:to_i).reduce(:+) } # 7
      parser = (first >> second).map { |value| value.reduce(:*) } # 21

      result = parser.run("1234")
      expect(result.captures).to eq(21)
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
  end

  describe 'choice' do
    it 'matches the first parser' do
      parser = string('hello') | string('world')
      result = parser.run('hello')

      expect(result.success?).to be_truthy
    end

    it 'matches the second parser' do
      parser = string('hello') | string('world')
      result = parser.run('world')

      expect(result.success?).to be_truthy
    end

    it 'returns failure if nothing matches' do
      parser = string('hello') | string('world')
      result = parser.run('!')

      expect(result.failure?).to be_truthy
    end

    it 'handles failing parser before success and continues' do
      parser = (string('hello') | string('world') | string('!')) >> string(" the ") >> string('end') | string('beginning')
      result = parser.run('! the beginning')

      expect(result.success?).to be_truthy
    end

    context 'captures' do
      it 'captures the result of the first parser' do
        parser = string('hello').capture! | string('world')
        result = parser.run('hello')

        expect(result.captures).to eq(['hello'])
      end

      it 'captures the result of the second parser' do
        parser = string('hello') | string('world').capture!
        result = parser.run('world')

        expect(result.captures).to eq(['world'])
      end

      it 'captures groups' do
        parser = (string('hello') | string('world')).capture!
        result = parser.run('world')

        expect(result.captures).to eq(['world'])
      end
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

  describe 'zero_or_more' do
    context 'when success' do
      it 'matches zero' do
        parser = string('hello').zero_or_more
        result = parser.run('')

        expect(result.success?).to be_truthy
        expect(result.value).to eq([])
      end

      it 'matches one' do
        parser = string('hello').zero_or_more
        result = parser.run('hello')

        expect(result.success?).to be_truthy
        expect(result.value).to eq(['hello'])
      end

      it 'matches many' do
        parser = string('a').zero_or_more
        result = parser.run('aaaaaaaaaaaaaaa')

        expect(result.success?).to be_truthy
        expect(result.value.join).to eq("aaaaaaaaaaaaaaa")
      end

      it 'matches with alias' do
        parser = (c('1') | c('2') | c('3')).rep0
        result = parser.run('123')

        expect(result.success?).to be_truthy
        expect(result.value.join).to eq("123")
      end
    end

    context 'when product' do
      it 'matches many' do
        parser = c("start") >> c("1").zero_or_more
        result = parser.run("start111end")

        expect(result.success?).to be_truthy
        expect(result.value).to eq(["start", ["1", "1", "1"]])
      end

      it 'many and then product' do
        parser = c("1").zero_or_more >> c("end")
        result = parser.run("111end")

        expect(result.success?).to be_truthy
        expect(result.value).to eq([["1", "1", "1"], "end"])
      end

      it 'many and then product' do
        parser = c("start") >> c("yo").zero_or_more >> c("end")
        result = parser.run("startyoyoyoyoend")
        expect(result.success?).to be_truthy
        expect(result.value.flatten(1)).to eq(["start", ["yo", "yo", "yo", "yo"], "end"])
      end
    end

    context 'when choice' do
      it 'matches all' do
        parser = (c("1") | c("2")).zero_or_more
        result = parser.run("121212")

        expect(result.success?).to be_truthy
        expect(result.value).to eq(["1", "2", "1", "2", "1", "2"])
      end

      it 'matches third choice' do
        parser = (c("1") | c("2") | c("3")).zero_or_more
        result = parser.run("3333")

        expect(result.success?).to be_truthy
        expect(result.value.join).to eq("3333")
      end

      it 'matches none' do
        parser = (c("1") | c("2") | c("3")).zero_or_more
        result = parser.run("4")

        expect(result.success?).to be_truthy
        expect(result.value).to eq([])
      end

    end

    context 'captures' do
      it 'captures the result of a parser' do
        parser = string('hello').zero_or_more.capture!
        result = parser.run('hello')

        expect(result.captures).to eq(['hello'])
      end

      it 'captures all matched many pairs' do
        parser = string('hello').zero_or_more.capture!
        result = parser.run('hellohellohello')

        expect(result.captures).to eq(['hello', 'hello', 'hello'])
      end
    end

  end

  describe 'one_or_more' do
    it 'matches one' do
      parser = string('hello').rep
      result = parser.run('hello')

      expect(result.success?).to be_truthy
      expect(result.value).to eq(['hello'])
    end

    it 'matches many' do
      parser = string('a').rep
      result = parser.run('aaaaaaaaaaaaaaa')

      expect(result.success?).to be_truthy
      expect(result.value.join).to eq("aaaaaaaaaaaaaaa")
    end

    it 'matches with alias' do
      parser = (c('1') | c('2') | c('3')).rep
      result = parser.run('231')

      expect(result.success?).to be_truthy
      expect(result.value.join).to eq("231")
    end

    it 'must at least match one' do
      parser = string('hello').rep
      result = parser.run('')

      expect(result.success?).to be_falsey
    end

    it 'must at least match one but choice returns values' do
      parser = (c('1') | c('2') | c('3')).rep | c('still')
      result = parser.run('still')

      expect(result.success?).to be_truthy
    end

    context 'when product' do
      it 'matches many' do
        parser = c("start") >> c("1").rep
        result = parser.run("start111end")

        expect(result.success?).to be_truthy
        expect(result.value).to eq(["start", ["1", "1", "1"]])
      end

      it 'many and then product' do
        parser = c("1").rep >> c("end")
        result = parser.run("111end")

        expect(result.success?).to be_truthy
        expect(result.value).to eq([["1", "1", "1"], "end"])
      end

      it 'many and then product' do
        parser = c("start") >> c("yo").rep >> c("end")
        result = parser.run("startyoyoyoyoend")
        expect(result.success?).to be_truthy
        expect(result.value.flatten(1)).to eq(["start", ["yo", "yo", "yo", "yo"], "end"])
      end
    end

    context 'when n!=1' do

      it 'fails, because repeat exactly 2 times' do
        parser = c("1").rep(2) >> c("end")
        result = parser.run("111end")

        expect(result.failure?).to be_truthy
      end

      it 'fails, because n_min is 2' do
        parser = c("1").rep(2) >> c("end")
        result = parser.run("1end")

        expect(result.failure?).to be_truthy
      end
    end
  end

  describe 'repeat' do
    context 'when lower bound' do
      it 'matches one' do
        parser = string('hello').repeat(n_min: 1)
        result = parser.run('hello')

        expect(result.success?).to be_truthy
        expect(result.value).to eq(['hello'])
      end

      it 'matches many' do
        parser = string('a').repeat(n_min: 1)
        result = parser.run('aaaaaaaaaaaaaaa')

        expect(result.success?).to be_truthy
        expect(result.value.join).to eq("aaaaaaaaaaaaaaa")
      end

      it 'fails, because n_min is 2' do
        parser = c("1").repeat(n_min: 2) >> c("end")
        result = parser.run("1end")

        expect(result.failure?).to be_truthy
      end
    end

    context 'when upper bound' do
      it 'matches one' do
        parser = string('hello').repeat(n_min: 1, n_max: 1)
        result = parser.run('hellohello')

        expect(result.success?).to be_truthy
        expect(result.value).to eq(['hello'])
      end

      it 'matches many' do
        parser = string('a').repeat(n_min: 1, n_max: 5)
        result = parser.run('aaaaaaaaaaaaaaa')

        expect(result.success?).to be_truthy
        expect(result.value.join).to eq("aaaaa")
      end
    end

    context 'captures' do
      it 'captures the result of a parser' do
        parser = string('hello').repeat(n_min: 1).capture!
        result = parser.run('hellohello')

        expect(result.captures).to eq(['hello', 'hello'])
      end

      it 'captures all matched many pairs' do
        parser = (string('hello') | c("world")).repeat(n_min: 1).capture!
        result = parser.run('worldhelloworld')

        expect(result.captures).to eq(['world', 'hello', 'world'])
      end
    end
  end

end
