# frozen_string_literal: true

require_relative "dolos/version"
require_relative "dolos/parser_state"
require_relative "dolos/result"
require_relative "dolos/string_io_wrapper"
require_relative "dolos/parsers"

module Dolos
  include Parsers
  class Parser

    attr_accessor :parser_proc

    def initialize(&block)
      @parser_proc = block
    end

    def run(input)
      run_with_state(ParserState.new(input))
    end

    def run_with_state(state)
      result = parser_proc.call(state)

      result
    end

    def flat_map(other_parser)
      Parser.new do |state|
        result1 = run_with_state(state)
        case result1
        when Success
          new_state = state.dup
          new_state.input.advance(result1.length)
          result2 = other_parser.run_with_state(new_state)
          case result2
          when Success
            Success.new(yield(result1.value, result2.value), result1.length + result2.length)
          else
            result2
          end
        else
          result1
        end
      end
    end
    def product(other_parser)
      flat_map(other_parser) do |value1, value2|
        Success.new([value1, value2], value1.length + value2.length)
      end
    end


    alias_method :>>, :product



  end
end
