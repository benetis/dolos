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

    def capture!(wrap_in = nil)
      Parser.new do |state|
        result = run_with_state(state)
        if result.success?
          result.capture!(wrap_in)
        else
          result
        end
      end
    end

    # Will call block on captures
    def map_captures(&block)
      Parser.new do |state|
        result = run_with_state(state)
        if result.success?
          Success.new(result.value, result.length, block.call(result.captures))
        else
          result
        end
      end
    end

    # Will call block on tuple of value
    def map(&block)
      Parser.new do |state|
        result = run_with_state(state)
        if result.success?
          Success.new(block.call(result.value), result.length, result.captures)
        else
          result
        end
      end
    end

    def combine(&block)
      Parser.new do |state|
        result = run_with_state(state)

        if result.success?
          state.input.advance(result.length)
          new_parser = block.call(result.value, result.captures)
          new_parser.run_with_state(state)
        else
          result
        end
      end
    end

    def flatten
      map_captures do |captures|
        captures.flatten
      end
    end

    def product(other_parser)
      combine do |value1, capture1|
        other_parser.map do |value2|
          [value1, value2]
        end.map_captures do |capture2|
          [capture1, capture2].flatten
        end
      end
    end
    alias_method :&, :product

    def product_l(other_parser)
      combine do |value1, capture1|
        other_parser.map do |_|
          value1
        end.map_captures do |capture2|
          [capture1, capture2].flatten
        end
      end
    end

    def product_r(other_parser)
      combine do |_, capture1|
        other_parser.map do |value2|
          value2
        end.map_captures do |capture2|
          [capture1, capture2].flatten
        end
      end
    end

    alias_method :<<, :product_l
    alias_method :>>, :product_r

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
    def repeat(n_min:, n_max: Float::INFINITY, separator: nil)
      Parser.new do |state|
        values = []
        captures = []
        count = 0
        state.input.mark_offset

        loop do
          result = run_with_state(state.dup)

          if result.failure? || count >= n_max
            break
          end

          values << result.value
          captures.concat(result.captures)
          state.input.advance(result.length)
          count += 1

          if separator && count < n_max
            sep_result = separator.run_with_state(state.dup)
            break if sep_result.failure?

            state.input.advance(sep_result.length)
          end
        end

        if count < n_min
          error_pos = state.input.offset
          Failure.new(
            -> { "Expected parser to match at least #{n_min} times but matched only #{count} times" },
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

    # Unstable API
    # Used to declare lazy parser to avoid infinite loops in recursive parsers
    def lazy
      parser_memo = nil

      Parser.new do |state|
        parser_memo ||= self
        parser_memo.run_with_state(state)
      end
    end

    private

    def combine_and_discard_empty(*arrays)
      arrays.compact.reject { |arr| arr.is_a?(Array) && arr.empty? }
    end

  end
end
