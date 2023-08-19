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
      if result.success?
        state.last_success_position = state.input.offset
      end
      result
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

    def choice(other_parser)
      Parser.new do |state|
        result = run_with_state(state)
        if result.success?
          result
        else
          other_parser.run_with_state(state)
        end
      end
    end
    alias_method :|, :choice

    # rep0         # 0 or more
    # rep          # 1 or more
    # rep(n = 2)   # exactly 2
    # repeat(n_min: 2, n_max: 4) # 2 to 4
    # repeat(n_min: 2) # 2 or more
    def repeat(n_min:, n_max: Float::INFINITY)
      Parser.new do |state|
        values = []
        captures = []
        count = 0
        state.input.mark_offset

        while count < n_max
          result = run_with_state(state.dup)

          break if result.failure?

          values << result.value
          captures.concat(result.captures)
          state.input.advance(result.length)
          count += 1
        end

        if count < n_min
          error_pos = state.input.offset
          Failure.new(
            "Expected parser to match at least #{n_min} times but matched only #{count} times",
            error_pos,
            state
          )
        else
          Success.new(values, 0, captures)
        end
      end
    end

    def zero_or_more
      repeat(n_min: 0, n_max: Float::INFINITY)
    end
    alias_method :rep0, :zero_or_more

    def one_or_more(exactly = nil)
      if exactly.nil?
        repeat(n_min: 1, n_max: Float::INFINITY)
      else
        repeat(n_min: exactly, n_max: exactly)
      end
    end
    alias_method :rep, :one_or_more

    def optional
      Parser.new do |state|
        result = run_with_state(state.dup)
        if result.success?
          result
        else
          Success.new([], 0)
        end
      end
    end
    alias_method :opt, :optional

    def lazy
      parser_memo = nil

      Parser.new do |state|
        parser_memo ||= self
        parser_memo.run_with_state(state)
      end
    end

  end
end
