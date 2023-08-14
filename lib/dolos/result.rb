# frozen_string_literal: true

module Dolos
  class Result
  end

  class Success < Result
    attr_reader :value, :length

    def initialize(value, length)
      @value = value
      @length = length
    end

    def inspect
      "Success(value: '#{value}',length: #{length})"
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
