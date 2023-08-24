## Letter address parser example

> Note: example code is available at [examples/letter.rb](https://github.com/benetis/dolos/blob/master/examples/letter.rb)

This example will show how to parse a letter address. It will be built from smaller parsers which are reusable and easy to understand.
Also, this example uses `.capture!` instead of default `>>`, `<<`, `&` product operators to build final values

```ruby
# frozen_string_literal: true
require 'dolos'

include Dolos
include Dolos::Common

# Library usage example
# Parse out a name and address from a letter
# For higher difficulty, we will not split this into multiple lines, but instead parse it all at once
letter = <<-LETTER
        Mr. Vardeniui Pavardeniui
        AB „Lietuvos Paštas“
        Totorių g. 8
        01121 Vilnius
LETTER

# Combine with 'or'
honorific = c("Mr. ") | c("Mrs. ") | c("Ms. ")

# Can be parsed any_char which will include needed letters
# Or combine LT letters with latin alphabet
alpha_with_lt = char_in("ąčęėįšųūžĄČĘĖĮŠŲŪŽ") | alpha

# Capture all letters in a row and join them,
# because they are captured as elements of array by each alpha_with_lt parser.
first_name = alpha_with_lt.rep.map(&:join).capture!
last_name = alpha_with_lt.rep.map(&:join).capture!

# Combine first line parsers
# Consume zero or more whitespace, after that honorific must follow and so on
name_line = ws_rep0 & honorific & first_name & ws & last_name & eol

# Next line is company info
# We could choose to accept UAB and AB or just AB and etc.
# 'c("AB")' is for case-sensitive string. 'string' can also be used
company_type = c("AB")
quote_open = c("„")
quote_close = c("“")

# Consume LT alphabet with whitespace
company_name = (alpha_with_lt | ws).rep.map(&:join).capture!
company_info = company_type & ws_rep0 & quote_open & company_name & quote_close
second_line = ws_rep0 & company_info & eol

# Address line
# 'char_while' will consume characters while passed predicate is true
# This could be an alternative to previous 'alpha_with_lt' approach
# After that result is captured and mapped to hash
# Mapping to hash so at the end its easy to tell tuples apart
# Also while mapping, doing some cleaning with '.strip'
street_name = char_while(->(char) { !char.match(/\d/) }).map { |s| { street: s.strip } }.capture!
building = digits.map { |s| { building: s.strip } }.capture!
address_line = ws_rep0 & street_name & building & eol

# City line
# All digits can be matched here or 'digits.rep(5)' could be used. Also joining with map.
postcode = digits.map { |s| { postcode: s.strip } }.capture!
city = alpha_with_lt.rep.map(&:join).map { |s| { city: s.strip } }.capture!
city_line = ws_rep0 & postcode & ws & city & eol

# Full letter parser which is combined from all previous parsers. All previous parsers can be ran separately.
letter_parser = name_line & second_line & address_line & city_line
result = letter_parser.run(letter)

pp result.captures
```