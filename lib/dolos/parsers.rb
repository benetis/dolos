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
  end
end
