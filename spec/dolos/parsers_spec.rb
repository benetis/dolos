# frozen_string_literal: true

require 'rspec'

RSpec.describe Dolos::Parsers do
  include Dolos
  describe 'string' do

    context 'when basic case' do
      it 'parses a string' do
        parser = string('hello')
        result = parser.run('hello')

        expect(result.success?).to be_truthy
      end

      it 'parses a string with alias' do
        parser = c('hello')
        result = parser.run('hello')

        expect(result.success?).to be_truthy
      end
    end

    context 'when special letters' do
      it 'parses a string with šįėę and etc.' do
        parser = c('šįėę')
        result = parser.run('šįėę')

        expect(result.success?).to be_truthy
      end

      it 'parses symbols like ?.@#$%^&*()_+' do
        parser = c('?.@#$%^&*()_+')
        result = parser.run('?.@#$%^&*()_+')

        expect(result.success?).to be_truthy
      end

    end

  end

  describe 'regex' do
    context 'when digits' do
      it 'parses digits' do
        parser = regex(/\d+/)
        result = parser.run('123')

        expect(result.success?).to be_truthy
        expect(result.value).to eq('123')
      end

      it 'only parses digits' do
        parser = regex(/\d+/)
        result = parser.run('123abc')

        expect(result.success?).to be_truthy
        expect(result.value).to eq('123')
      end

      it 'converts to integer' do
        parser = regex(/\d/).capture!.map { |capt| capt.map(&:to_i) }
        result = parser.run('1')

        expect(result.success?).to be_truthy
        expect(result.captures).to eq([1])
      end

      it 'converts to integer' do
        parser = regex(/\d+/).capture!.map { |capt| capt.map(&:to_i) }
        result = parser.run('123')

        expect(result.success?).to be_truthy
        expect(result.captures).to eq([123])
      end
    end

    context 'product' do
      it 'parses two regexes' do
        digits = regex(/\d+/)
        letters = regex(/[a-z]+/)
        parser = digits >> letters
        result = parser.run('123abc')

        expect(result.success?).to be_truthy
        expect(result.value).to eq(['123', 'abc'])
      end

      it 'parses three regexes' do
        digits = regex(/\d+/)
        letters = regex(/[a-z]+/)
        parser = letters >> digits >> letters
        result = parser.run('a123abchello')

        expect(result.success?).to be_truthy
        expect(result.value).to eq([["a", "123"], "abchello"])
      end

      it 'parses a regex and a string' do
        digits = regex(/\d+/)
        hello = c('hello')

        parser = digits >> hello
        result = parser.run('123hello')

        expect(result.success?).to be_truthy
        expect(result.value).to eq(['123', 'hello'])
      end

      it 'parses a string and a regex' do
        digits = regex(/\d+/)
        hello = c('hello')

        parser = hello >> digits
        result = parser.run('hello123')

        expect(result.success?).to be_truthy
        expect(result.value).to eq(['hello', '123'])
      end

      it 'fails because regex consumes all the letters' do
        digits = regex(/\d+/)
        letters = regex(/[a-z]+/)
        parser = letters >> digits >> letters >> c("missing")
        result = parser.run('a123abchellomissing')

        expect(result.failure?).to be_truthy
      end
    end

    context 'special characters' do
      it 'parses a regex with special characters' do
        parser = regex(/šįėę/)
        result = parser.run('šįėę')

        expect(result.success?).to be_truthy
        expect(result.value).to eq('šįėę')
      end

      it 'parses special characters and does product' do
        parser = regex(/ąąąą/) >> regex(/žžžž/)
        result = parser.run('ąąąąžžžž')

        expect(result.success?).to be_truthy
        expect(result.value).to eq(['ąąąą', 'žžžž'])
      end

      it 'works with repeat' do
        ws = regex(/\s/)
        parser = ws.rep0
        result = parser.run('   ')

        expect(result.success?).to be_truthy
        expect(result.value).to eq([' ', ' ', ' '])
      end

      it 'works with repeat and product' do
        ws = regex(/\s/)
        parser = ws.rep >> c("123")
        result = parser.run('   123')

        expect(result.success?).to be_truthy
        expect(result.value).to eq([[' ', ' ', ' '], '123'])
      end

      it 'doesnt overconsume' do
        ws = regex(/\s/)
        parser = ws.rep >> c("123")
        result = parser.run('   123  ')

        expect(result.success?).to be_truthy
        expect(result.value).to eq([[' ', ' ', ' '], '123'])
      end
    end
  end

  describe 'any_char' do
    context 'when basic case' do
      it 'parses a single character' do
        parser = any_char
        result = parser.run('a')

        expect(result.success?).to be_truthy
        expect(result.value).to eq('a')
      end

      it 'parses a single character' do
        parser = any_char
        result = parser.run('b')

        expect(result.success?).to be_truthy
        expect(result.value).to eq('b')
      end
    end

    context 'when special characters' do
      it 'parses a single character' do
        parser = any_char
        result = parser.run('š')

        expect(result.success?).to be_truthy
        expect(result.value).to eq('š')
      end
    end

    context 'with combinators' do
      it 'parses a single character and chains' do
        parser = any_char >> any_char >> any_char
        result = parser.run('šįėę')

        expect(result.success?).to be_truthy
        expect(result.value.flatten).to eq(['š', 'į', 'ė'])
      end

      it 'captures a date' do
        year = c("Year: ") >> any_char.rep(4).map(&:join).capture!
        month = c("Month: ") >> any_char.rep(2).map(&:join).capture!
        day = c("Day: ") >> any_char.rep(2).map(&:join).capture!
        sep = c(", ")

        parser = year >> sep >> month >> sep >> day

        result = parser.run('Year: 2019, Month: 01, Day: 01')
        expect(result.success?).to be_truthy
        expect(result.captures).to eq(['2019', '01', '01'])
      end
    end
  end

  describe 'char_in' do
    it 'parses a single character' do
      parser = char_in('abc')
      result = parser.run('b')

      expect(result.success?).to be_truthy
      expect(result.value).to eq('b')
    end

    it 'parses a single character with choice' do
      parser = char_in('abc') | char_in('def')
      result = parser.run('e')

      expect(result.success?).to be_truthy
      expect(result.value).to eq('e')
    end

    it 'parses a single character with product' do
      parser = char_in('abc') >> char_in('def')
      result = parser.run('ad')

      expect(result.success?).to be_truthy
      expect(result.value).to eq(['a', 'd'])
    end
  end

  describe 'char_while' do
    it 'should consume all non-whitespace characters' do
      non_whitespace_parser = char_while(->(char) { !char.match?(/\s/) })
      result = non_whitespace_parser.run("hello world")

      expect(result.success?).to be_truthy
      expect(result.value).to eq('hello')
    end

    it 'should not consume anything if its false' do
      non_whitespace_parser = char_while(->(_) { false })
      result = non_whitespace_parser.run("hi")

      expect(result.failure?).to be_truthy
    end

    context 'with combinators' do
      it 'should consume all non-whitespace characters' do
        non_whitespace_parser = char_while(->(char) { !char.match?(/\s/) })
        parser = non_whitespace_parser >> c(" ") >> c('world')
        result = parser.run("hello world")

        expect(result.success?).to be_truthy
        expect(result.value.flatten).to eq(['hello', ' ', 'world'])
      end
    end
  end



end
