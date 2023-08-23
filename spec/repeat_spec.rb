# frozen_string_literal: true

RSpec.describe Dolos do
  include Dolos
  include Dolos::Common

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

      it 'matches all whitespace' do
        parser = c(" ").rep0 & c("hmm") & string('hello').capture!
        result = parser.run('   hmmhello')

        expect(result.success?).to be_truthy
        expect(result.captures).to eq(["hello"])
      end
    end

    context 'when product' do
      it 'matches many' do
        parser = c("start") & c("1").zero_or_more
        result = parser.run("start111end")

        expect(result.success?).to be_truthy
        expect(result.value).to eq(["start", ["1", "1", "1"]])
      end

      it 'many and then product' do
        parser = c("1").zero_or_more & c("end")
        result = parser.run("111end")

        expect(result.success?).to be_truthy
        expect(result.value).to eq([["1", "1", "1"], "end"])
      end

      it 'many and then product' do
        parser = c("start") & c("yo").zero_or_more & c("end")
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
        parser = c("start") & c("1").rep
        result = parser.run("start111end")

        expect(result.success?).to be_truthy
        expect(result.value).to eq(["start", ["1", "1", "1"]])
      end

      it 'many and then product' do
        parser = c("1").rep & c("end")
        result = parser.run("111end")

        expect(result.success?).to be_truthy
        expect(result.value).to eq([["1", "1", "1"], "end"])
      end

      it 'many and then product' do
        parser = c("start") & c("yo").rep & c("end")
        result = parser.run("startyoyoyoyoend")
        expect(result.success?).to be_truthy
        expect(result.value.flatten(1)).to eq(["start", ["yo", "yo", "yo", "yo"], "end"])
      end
    end

    context 'when n!=1' do

      it 'fails, because repeat exactly 2 times' do
        parser = c("1").rep(2) & c("end")
        result = parser.run("111end")

        expect(result.failure?).to be_truthy
      end

      it 'fails, because n_min is 2' do
        parser = c("1").rep(2) & c("end")
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
        parser = c("1").repeat(n_min: 2) & c("end")
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

      it 'capture after repeat' do
        input = "+37061111111|+37061111112,861111113"
        sep = c(",") | c("|")
        num_start = c("+370") | c("8")
        num_rest = digits.capture!

        number = num_start & num_rest

        parser = (number & sep.opt).rep

        result = parser.run(input)

        expect(result.captures).to eq(["61111111", "61111112", "61111113"])
      end
    end

    context 'when separator' do
      let(:int_literal) { regex(/-?\d+/) }
      let(:comma) { regex(/,\s*/) }

      let(:repeated_ints) { int_literal.repeat(n_min: 2, n_max: 4, separator: comma) }

      it 'recognizes valid separated sequences' do
        expect(repeated_ints.run('1, 2, 3').success?).to be_truthy
        expect(repeated_ints.run('1,2,3,4').success?).to be_truthy
      end

      it 'stops on missing separator' do
        result = repeated_ints.run('1 2, 3')

        expect(result.failure?).to be_truthy
      end

      it 'respects the n_min constraint' do
        result = repeated_ints.run('1')
        expect(result.failure?).to be_truthy
      end

      it 'respects the n_max constraint' do
        expect(repeated_ints.run('1, 2, 3, 4, 5').value).to eq(['1', '2', '3', '4'])
      end
    end
  end

end