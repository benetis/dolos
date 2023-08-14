# frozen_string_literal: true

require 'stringio'

module Dolos
  class StringIOWrapper
    attr_reader :io, :offset, :backup

    def initialize(str)
      if str.is_a?(String)
        @io = StringIO.new(str.encode('UTF-8'))
      else
        @io = str
      end
      @io.set_encoding('UTF-8')
      @offset = 0
    end

    def mark_offset
      @backup = offset
    end

    def rollback
      @offset = backup
      io.seek(offset)
    end

    def matches?(utf8_str)
      read = io.read(utf8_str.bytesize)
      io.seek(offset)

      if read.nil?
        false
      else
        read.force_encoding('UTF-8') == utf8_str
      end
    end

    def advance(bytesize)
      @offset += bytesize
      io.seek(offset)
    end

  end

end
