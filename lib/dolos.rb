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
      parser_proc.call(state)
    end

    def capture!
      Parser.new do |state|
        result = run_with_state(state)
        if result.success?
          result.capture!
        else
          result
        end
      end
    end

    def map(&block)
      Parser.new do |state|
        result = run_with_state(state)
        if result.success?
          Success.new(result.value, result.length, block.call(result.captures))
        else
          result
        end
      end
    end

    def map_value(&block)
      Parser.new do |state|
        result = run_with_state(state)
        if result.success?
          Success.new(block.call(result.value), result.length, result.captures)
        else
          result
        end
      end
    end

    def flat_map(&block)
      Parser.new do |state|
        result = run_with_state(state)
        if result.success?
          new_parser = block.call(result.value, result.captures)
          new_state = state.dup
          new_state.input.advance(result.length)
          new_parser.run_with_state(new_state)
        else
          result
        end
      end
    end

    def flatten
      map do |captures|
        captures.flatten
      end
    end

    def product(other_parser)
      flat_map do |value1, capture1|
        other_parser.map_value do |value2|
          [value1, value2]
        end.map do |capture2|
          [capture1, capture2].flatten
        end
      end
    end
    alias_method :>>, :product



  end
end
