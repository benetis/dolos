# frozen_string_literal: true


require_relative 'dolos'

include Dolos

parser = string('hello')

result = parser.run('hello')

pp result.inspect


