# frozen_string_literal: true

module Dolos
  # Common parsers
  # Separated from the main library to improve them later on
  # These will change, new ones will be added. Once API stabilises, we will see what to do
  # We have to be careful what is in the scope when we include this main module
  # Probably a package of parsers following some RFC will be added as well.
  # Keeping them separate for now
  module Common
    def ws
      regex(/\s/)
    end

    def ws_rep0
      regex(/\s*/)
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
