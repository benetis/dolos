require 'dolos'

include Dolos
include Dolos::Common

# Phone numbers can be in different formats.
# For example, in Lithuania they can be in format `+370 612 34567` or `+37061234567` or `861234567`.
# Lets assume that any spaces after prefix should be ignored as different people can write them differently.
# Numbers are separated by , or |
# Let's not assume numbers are specific length in case we want to add more countries later
# Let's write a parser which will normalize them to `+37061234567` format.

input = "+370 612 34567, +37061234567|861234567   , 860123456"

# Two possible prefixes
prefix_370 = c("+370")
prefix_8 = c("8")

# Either prefix_370 or prefix_8 with `|
lt_prefix = prefix_370 | prefix_8

# `digit` matches on digit and `ws` matches one whitespaces
# `.rep` matches on one or more of the previous parser
only_digits = (digit | ws).rep.map { |result| result.reject { |d| d == ' ' }.join }

# `>>` is a combination or product operator, discards value on the left
# `ws_rep0` matches on zero or more whitespaces
lt_number = lt_prefix >> only_digits

# translates to: match all whitespaces, then match a , or |, then match all whitespaces
separator = ws_rep0 >> (c(",") | c("|")) >> ws_rep0

# repeats `number` parser at least once
# in between numbers there should be a separator, which is another parser
all_numbers = lt_number.repeat(n_min: 1, separator: separator)

result = all_numbers.run(input)

puts result.inspect # => Success(value: '["61234567", "61234567", "61234567", "60123456"]',length: 0, capture: '[]')

# Let's say we now we need to support numbers with prefix +1
# and after parsing, tag them as US numbers or LT numbers

with_us_input = "+1 123 456 7890,+370 612 34567, +37061234567|861234567   , 860123456"

us_int_prefix = c("+1")
# Result can be mapped to a hash with named result
# { US: "123456789" }
# Reuse `only_digits` parser
us_number = us_int_prefix >> only_digits.map { |d| { US: d } }

# Also name LT number
lt_number = lt_prefix >> only_digits.map { |d| { LT: d } }

number = us_number | lt_number

# Reuse separator
all_numbers = number.repeat(n_min: 1, separator: separator)

puts all_numbers.run(with_us_input).inspect
# => Success(value: '[{:US=>"1234567890"}, {:LT=>"61234567"}, {:LT=>"61234567"}, {:LT=>"61234567"}, {:LT=>"60123456"}]',length: 0, capture: '[]')





