# frozen_string_literal: true

module Dolos
  class ParserState
    attr_reader :input

    def initialize(input)
      @input = StringIOWrapper.new(input)
    end
  end

end
