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

    def captures
      []
    end
  end
end
