# Dolos

<img height="256" src="docs/dolos_stable_diff.png" width="256"/>


### Disclaimer
🚧 Under development, not stable yet 🚧

### Parser combinator library for Ruby

It does not use exceptions and instead returns a result object.
Library is composable and concise.

### Getting started

#### Installation
- Update Gemfile with `gem 'dolos'`
- Run bundle install

#### Usage
```ruby
require 'dolos'
include Dolos

ws = c(" ")
parser = c("Parsers") >> ws >> c("are") >> ws >> c("great!")
parser.run("Parsers are great!") # <Result::Success>

greeter = c("Hello")
greet_and_speak = greeter >> c(", ") >> parser
greet_and_speak.run("Hello, Parsers are great!") # <Result::Success>
```

### Letter address parser example
```ruby
require 'dolos'
require 'dolos_common_parsers/common_parsers'

include Dolos

# Include common parsers
# In future this can be more structured, 
# moved them to separate module to prevent breaking changes
include Dolos::CommonParsers

# Library usage example
# Parse out a name and address from a letter
# For higher difficulty, we will not split this into multiple lines, 
# but instead parse it all at once
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
first_name = alpha_with_lt.rep.capture!.map(&:join)
last_name = alpha_with_lt.rep.capture!.map(&:join)

# Combine first line parsers
# Consume zero or more whitespace, after that honorific must follow and so on
name_line = ws.rep0 >> honorific >> first_name >> ws >> last_name >> eol

# Next line is company info
# We could choose to accept UAB and AB or just AB and etc.
# 'c("AB")' is for case-sensitive string. 'string' can also be used
company_type = c("AB")
quote_open = c("„")
quote_close = c("“")

# Consume LT alphabet with whitespace
company_name = (alpha_with_lt | ws).rep.capture!.map(&:join)
company_info = company_type >> ws.rep0 >> quote_open >> company_name >> quote_close
second_line = ws.rep0 >> company_info >> eol

# Address line
# 'char_while' will consume characters while passed predicate is true
# This could be an alternative to previous 'alpha_with_lt' approach
# After that result is captured and mapped to hash
# Mapping to hash so at the end its easy to tell tuples apart
# Also while mapping, doing some cleaning with '.strip'
street_name = char_while(->(char) { !char.match(/\d/) })
  .capture!
  .map(&:first)
  .map { |s| { street: s.strip } }
building = digits.capture!.map(&:first).map { |s| { building: s.strip } }
address_line = ws.rep0 >> street_name >> building >> eol

# City line
# All digits can be matched here or 'digits.rep(5)' could be used. 
# Also joining with map results.
postcode = digits.capture!.map(&:join).map { |s| { postcode: s.strip } }
city = alpha_with_lt.rep.capture!.map(&:join).map { |s| { city: s.strip } }
city_line = ws.rep0 >> postcode >> ws >> city >> eol

# Full letter parser which is combined from all previous parsers.
# Also, all previous parsers can be ran separately.
letter_parser = name_line >> second_line >> address_line >> city_line
result = letter_parser.run(letter)

# List of tuples
pp result.captures
# ["Vardeniui", "Pavardeniui", "Lietuvos Paštas", {:street=>"Totorių g."},
# {:building=>"8"}, {:postcode=>"01121"}, {:city=>"Vilnius"}]

```

### Contributing
Contributors are welcome. Note: since library is not yet stable, I recommend getting in touch with me before starting to work on something.

#### Other parser combinator libraries
- [Fastparse](https://com-lihaoyi.github.io/fastparse/) (Scala)
- [Parsby](https://github.com/jolmg/parsby) (Ruby)