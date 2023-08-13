# frozen_string_literal: true

require 'stringio'

module Dolos
  class StringIOWrapper
    attr_reader :io, :offset, :backup

    def initialize(str)
      if str.is_a?(String)
        @io = StringIO.new(str)
      else
        @io = str
      end
      @offset = 0
    end

    def mark_offset
      @backup = offset
    end

    def rollback
      @offset = backup
      io.seek(offset)
    end

    def matches?(str)
      read = io.read(str.length)

      if read.nil?
        return false
      else
        advance(read.length)

        read == str
      end
    end

    def advance(length)
      @offset += length
      io.seek(offset)
    end

  end

end
