# frozen_string_literal: true

require 'dolos_common_parsers/common_parsers'
RSpec.describe Dolos do
  include Dolos
  include Dolos::CommonParsers

  describe 'recursive' do

    context 'when successful' do
      it 'repeats a parser' do
        parser = recursive do |content|
          string('hello').lazy >> content.opt
        end

        result = parser.run('hellohellohello')

        expect(result.success?).to be_truthy
        expect(result.value.flatten).to eq(['hello', 'hello', 'hello'])
      end

      it 'parses brackets' do
        bracketed = recursive do |content|
          open_bracket = c('(')
          close_bracket = c(')')
          open_bracket >> content.opt >> close_bracket
        end

        result = bracketed.run('(())')

        expect(result.success?).to be_truthy
        expect(result.value.flatten).to eq(['(', '(', ')', ')'])
      end

      it 'parses brackets with content, matches brackets' do
        bracketed = recursive do |content|
          open_bracket = c('(')
          close_bracket = c(')')
          open_bracket >>
            (content | string('hello').capture!).opt >>
            close_bracket
        end

        result = bracketed.rep.run('()((hello))')

        expect(result.success?).to be_truthy
        expect(result.captures).to eq(['hello'])
      end
    end

  end

  context 'when failure' do
    it 'fails if parser fails' do
      parser = recursive do |content|
        string('hello') >> content.opt
      end

      result = parser.run('goodbyehello')

      expect(result.failure?).to be_truthy
    end
  end

  context 'when recursive parsers reference each other' do
    let(:digits_int) { digits.capture!.map(&:first).map(&:to_i) }
    let(:paren_expr) { (c('(') >> expression.lazy >> c(')')) }
    let(:factor) do
      paren_expr | digits_int
    end

    let(:divide_multiple) do
      recursive do |expr_placeholder|
        (factor >> ((c('*') | c('/')) >> expr_placeholder).opt)
      end
    end

    let(:expression) {
      recursive do |expr_placeholder|
        (divide_multiple.lazy >> ((c('+') | c('-')) >> expr_placeholder).opt)
      end
    }

    context 'simple arithmetic' do
      it 'parses a number' do
        result = expression.run('123')
        expect(result.success?).to be_truthy
        expect(result.captures).to eq([123])
      end

      it 'parses a number in parens' do
        result = expression.run('(123)')
        expect(result.success?).to be_truthy
        expect(result.captures).to eq([123])
      end

      it 'parses 1+2 and returns 3' do
        result = expression.run('1+2')
        puts result.inspect
        expect(result.success?).to be_truthy
        expect(result.captures).to eq([3])
      end

    end

  end

end


