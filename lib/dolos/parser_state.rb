# frozen_string_literal: true

module Dolos
  class ParserState
    attr_reader :input
    attr_accessor :last_success_position

    def initialize(input)
      @input = StringIOWrapper.new(input)
      @last_success_position = 0
    end
  end
end

