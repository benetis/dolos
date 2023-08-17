# frozen_string_literal: true

require 'dolos_common_parsers/common_parsers'
RSpec.describe Dolos do
  include Dolos
  include Dolos::CommonParsers

  describe 'recursive' do

    context 'when successful' do
      it 'repeats a parser' do
        parser = recursive do |content|
          string('hello') >> content.opt
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
    end

    context 'when addition' do
      it 'parses brackets, digits and addition' do
        def term
          recursive do |t|
            ws.opt >>
              (digit.map_value { |d| d.to_i } |
                (c("(") >> expr >> c(")")).map_value { |_, e, _| e }) >>
              ws.opt
          end
        end

        def expr
          recursive do |exp|
            left_term = term
            rest = (ws.opt >> c("+") >> ws.opt >> exp).map_value { |_, _, _, e| e }
            (left_term >> rest).map_value { |l, r| l + r } | term
          end
        end

        expect(expr.run("1 + 2 + 3").value).to eq(6)
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

end

