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

    # Run the parser with the given input
    # Returns a Result<Success|Failure>
    # string("hello").run("hello") => Success.new("hello", 5)
    def run(input)
      run_with_state(ParserState.new(input))
    end


    def run_with_state(state)
      result = @parser_proc.call(state)
      state.last_success_position = state.input.offset if result.success?
      result
    end

    # Capture the result of the parser
    # p = string("hello").capture!
    # p.run("hello").captures => ["hello"]
    # Captures is a flat array of all captured values
    def capture!(wrap_in = nil)
      Parser.new do |state|
        result = run_with_state(state)
        result.success? ? result.capture!(wrap_in) : result
      end
    end

    # Map the captures of the parser
    # p = string("hello").map_captures { |captures| captures.map(&:upcase) }
    # p.run("hello") => Success.new("hello", 5, ["HELLO"])
    # This only maps over captures, not the value
    def map_captures(&block)
      Parser.new do |state|
        result = run_with_state(state)
        result.success? ? Success.new(result.value, result.length, block.call(result.captures)) : result
      end
    end

    # Map the result of the parser
    # p = string("hello").map { |s| s.upcase }
    # p.run("hello") => Success.new("HELLO", 5)
    def map(&block)
      Parser.new do |state|
        result = run_with_state(state)
        result.success? ? Success.new(block.call(result.value), result.length, result.captures) : result
      end
    end

    # Combine the result of the parser with another parser
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

    # Combine the result of the parser with another parser
    # Has an alias of `&`
    # p = string("hello") & string("world")
    # p.run("helloworld") => Success.new(["hello", "world"], 10)
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


    # Combine the result of the parser with another parser
    # Discards the result of the second parser
    # p = string("hello") << string("world")
    def product_l(other_parser)
      combine do |value1, capture1|
        other_parser.map do |_|
          value1
        end.map_captures do |capture2|
          [capture1, capture2].flatten
        end
      end
    end

    # Combine the result of the parser with another parser
    # Discards the result of the first parser
    # p = string("hello") >> string("world")
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

    # Combine the result of the parser with another parser
    # If the first parser fails, it will try the second parser
    # p = string("hello") | string("world") | string("!")
    # p.run("hello") => Success.new("hello", 5)
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


    # Repeat the parser n times
    # Separator is optional, its another parser that will be run between each repetition
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

        loop do
          result = run_with_state(state) # Removing .dup for performance. Be cautious of side effects.

          if result.failure? || count >= n_max
            break
          end

          values << result.value
          captures.concat(result.captures)
          state.input.advance(result.length)
          count += 1

          if separator && count < n_max
            sep_result = separator.run_with_state(state) # Removing .dup for performance. Be cautious of side effects.
            break if sep_result.failure?

            state.input.advance(sep_result.length)
          end
        end

        if count < n_min
          Failure.new(
            -> { "Expected parser to match at least #{n_min} times but matched only #{count} times" },
            state.input.offset,
            state
          )
        else
          Success.new(values, 0, captures)
        end
      end
    end

    # Repeat the parser zero or more times
    # c(" ").rep0.run("   ") => Success.new([" ", " ", " "], 3)
    def zero_or_more
      repeat(n_min: 0, n_max: Float::INFINITY)
    end
    alias_method :rep0, :zero_or_more

    # Repeat the parser one or more times
    # Same as rep0, but must match at least once
    # c(" ").rep.run("A") => Failure.new("...")
    def one_or_more(exactly = nil)
      if exactly.nil?
        repeat(n_min: 1, n_max: Float::INFINITY)
      else
        repeat(n_min: exactly, n_max: exactly)
      end
    end
    alias_method :rep, :one_or_more

    # Make parser optional
    # c(" ").opt.run("A") => Success.new([], 0)
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

    # Used to declare lazy parser to avoid infinite loops in recursive parsers
    def lazy
      parser_memo = nil

      Parser.new do |state|
        parser_memo ||= self
        parser_memo.run_with_state(state)
      end
    end

  end
end
