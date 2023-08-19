# frozen_string_literal: true

module Dolos
  module CommonParsers
    def ws
      regex(/\s/)
    end

    def eol
      regex(/\n|\r\n|\r/)
    end

    def digit
      regex(/\d/)
    end

    def int
      digit.map(&:to_i)
    end

    # Capture as string
    def digits
      regex(/\d+/)
    end

    def alpha_num
      regex(/[a-zA-Z0-9]/)
    end

    def alpha
      regex(/[a-zA-Z]/)
    end
  end
end
