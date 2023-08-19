# frozen_string_literal: true

module Dolos
  class Result
  end

  class Success < Result
    attr_reader :value, :length, :captures

    def initialize(value, length, captures = [])
      @value = value
      @length = length
      @captures = captures
    end

    # can be some named capture, :street, {:street => capture }
    # or an array, [], [capture]
    def capture!(wrap_in = nil)
      if wrap_in.is_a?(Array)
        save_capture([value])
      elsif wrap_in.is_a?(Symbol)
        save_capture({ wrap_in => value })
      else
        save_capture(value)
      end
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

    private

    def save_capture(val)
      if val.is_a?(Array)
        val.each do |v|
          captures << v
        end
      else
        captures << val
      end

      Success.new(val, length, captures)
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
