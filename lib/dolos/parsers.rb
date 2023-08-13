# frozen_string_literal: true

module Dolos
  module Parsers
    def string(str)
      Parser.new do |state|
        state.input.mark_offset
        if state.input.matches?(str)
          Success.new(str, str.length)
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
  end
end
