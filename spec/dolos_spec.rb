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

  describe 'optional' do
    it 'matches' do
      parser = string('hello').optional
      result = parser.run('hello')

      expect(result.success?).to be_truthy
      expect(result.value).to eq('hello')
    end

    it 'does not match' do
      parser = string('hello').optional
      result = parser.run('')

      expect(result.success?).to be_truthy
      expect(result.value).to eq([])
    end

    it 'captures' do
      parser = string('hello').optional.capture!
      result = parser.run('hello')

      expect(result.captures).to eq(['hello'])
    end

    it 'captures nothing' do
      parser = string('hello').optional.capture!
      result = parser.run('')

      expect(result.captures).to eq([])
    end

    context 'when product' do
      it 'matches optional part' do
        parser = c("start") >> c("1").optional >> c("end")
        result = parser.run("start1end")

        expect(result.success?).to be_truthy
        expect(result.value.flatten).to eq(["start", "1", "end"])
      end

      it 'skips optional part' do
        parser = c("start") >> c("1").optional >> c("end")
        result = parser.run("startend")

        expect(result.success?).to be_truthy
        expect(result.value.flatten).to eq(["start", "end"])
      end

      it 'doesnt match the input - it will not make it optional' do
        parser = c("start") >> c("1").optional >> c("end")
        result = parser.run("start2end")

        expect(result.success?).to be_falsey
      end
    end
  end

end
