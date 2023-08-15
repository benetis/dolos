# frozen_string_literal: true

module Dolos
  module CommonParsers
    def ws
      regex(/\s+/)
    end

    # Convert to integer
    def digit
      regex(/\d/).capture!.map { |capt| capt.map(&:to_i) }
    end

    # Capture as string
    def digits
      regex(/\d+/)
    end

    def alpha_num
      regex(/[a-zA-Z0-9]/)
    end
  end
end
