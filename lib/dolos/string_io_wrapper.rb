# frozen_string_literal: true

require 'stringio'

module Dolos
  class StringIOWrapper
    attr_reader :io, :offset, :backup

    def initialize(str)
      @io = StringIO.new(str.encode('UTF-8'))
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

    # A bit tricky, like this whole library
    # Since utf8 characters can be multiple bytes long, we need to
    # read the next byte and check if it's a valid utf8 character
    def peek(bytesize)
      current_position = io.pos
      data = io.read(bytesize)
      io.seek(current_position)

      return nil if data.nil?

      while !data.force_encoding('UTF-8').valid_encoding? && bytesize < 4 # a UTF-8 character can be at most 4 bytes long
        bytesize += 1
        data = io.read(bytesize)
        io.seek(current_position)
      end

      [data.force_encoding('UTF-8'), bytesize]
    end


    def matches_regex?(pattern)
      current_position = io.pos
      remaining_data = io.read
      io.seek(current_position)

      if (match_data = remaining_data.match(pattern))
        matched_string = match_data[0]
        return matched_string
      end

      nil
    end


  end

end
