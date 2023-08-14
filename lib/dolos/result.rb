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
        last_value = [value.last]
      else
        last_value = [value]
      end

      Success.new(value, length, captures.concat(last_value).flatten)
    end

    # def capture!
    #   Success.new(value, length, captures.concat([value]).flatten)
    # end

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
    attr_reader :message, :committed

    def initialize(message, committed)
      @message = message
      @committed = committed
    end

    def inspect
      "Failure(#{message.inspect}, #{committed})"
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
  end
end
