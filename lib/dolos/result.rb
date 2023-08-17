# frozen_string_literal: true

module Dolos
  class Result
  end

  class Success < Result
    attr_reader :value, :length, :captures

    def initialize(value, length, captures = [])
      @value = value
      @length = length
      # @captures = captures || value
      @captures = captures
    end

    def capture!
      if value.is_a?(Array)
        value.each do |v|
          captures << v
        end
      else
        captures << value
      end

      Success.new(value, length, captures)
    end

    def inspect
      "Success(value: '#{value}',length: #{length}, capture: '#{captures}')"
    end

    def success?
      true
    end

    def failure?
      false
    end
  end

  class Failure < Result
    attr_reader :message, :error_position, :state

    def initialize(message, error_position, state)
      @message = message
      @error_position = error_position
      @state = state
    end

    def inspect
      pretty_print
    end

    def pretty_print
      input_string = state.input.io.string

      pointer = "^" # This will point to the error position

      context_range = 10 # Chars before and after the error to display

      start_index = [error_position - context_range, 0].max
      end_index = [error_position + context_range, input_string.length].max

      substring = input_string[start_index..end_index]

      padding = error_position - start_index

      [
        "Failure: #{message}",
        substring,
        "#{' ' * padding}#{pointer}",
        "Error Position: #{error_position}, Last Success Position: #{state.last_success_position}"
      ].join("\n")
    end

    def map
      self
    end

    def success?
      false
    end

    def failure?
      true
    end

    def captures
      []
    end
  end
end
