# frozen_string_literal: true

module Dolos
  module Parsers
    def string(str)
      Parser.new do |state|
        state.input.mark_offset
        utf8_str = str.encode('UTF-8')
        if state.input.matches?(utf8_str)
          Success.new(utf8_str, str.bytesize)
        else
          advanced = state.input.offset
          state.input.rollback
          Failure.new(
            "Expected #{str.inspect} but got #{state.input.io.string.inspect}",
            advanced
          )
        end
      end
    end
    alias_method :c, :string

    def regex(pattern)
      Parser.new do |state|
        state.input.mark_offset
        if (matched_string = state.input.matches_regex?(pattern))
          Success.new(matched_string, matched_string.bytesize)
        else
          advanced = state.input.offset
          state.input.rollback
          Failure.new(
            "Expected pattern #{pattern.inspect} but got #{state.input.io.string.inspect}",
            advanced
          )
        end
      end
    end


    def any_char
      Parser.new do |state|
        state.input.mark_offset

        char, = state.input.peek(1)

        if char && !char.empty?
          Success.new(char, char.bytesize)
        else
          advanced = state.input.offset
          state.input.rollback
          Failure.new('Expected any character but got end of input', advanced)
        end
      end
    end

    # Matches any character in a string
    # Example:
    #  char_in('abc').run('b') # => Success.new('b', 1)
    def char_in(characters_string)
      characters_array = characters_string.chars

      Parser.new do |state|
        state.input.mark_offset

        char, bytesize = state.input.peek(1)

        if char && characters_array.include?(char)
          Success.new(char, bytesize)
        else
          advanced = state.input.offset
          state.input.rollback
          Failure.new(
            "Expected one of #{characters_array.inspect} but got #{char.inspect}",
            advanced
          )
        end
      end
    end

    def char_while(predicate)
      Parser.new do |state|
        state.input.mark_offset

        buffer = String.new
        loop do
          char, bytesize = state.input.peek(1)
          break if char.nil? || !predicate.call(char)

          buffer << char
          state.input.advance(bytesize)
        end

        if buffer.empty?
          advanced = state.input.offset
          Failure.new("Predicate never returned true", advanced)
        else
          Success.new(buffer, 0)
        end
      end
    end

  end
end
