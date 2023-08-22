# Dolos
[![Gem version](https://badge.fury.io/rb/dolos.svg)](https://rubygems.org/gems/dolos)
[![Build status](https://github.com/benetis/dolos/actions/workflows/ruby.yml/badge.svg)](https://github.com/benetis/dolos/actions)


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
parser = c("Parsers") & ws & c("are") & ws & c("great!")
parser.run("Parsers are great!") # <Result::Success>

greeter = c("Hello")
greet_and_speak = greeter & c(", ") & parser
greet_and_speak.run("Hello, Parsers are great!") # <Result::Success>
```

### Letter address parser example

```ruby
require 'dolos'
require 'dolos_common_parsers/common_parsers'

include Dolos
# frozen_string_literal: true
require_relative 'dolos'
require_relative 'dolos_common_parsers/common_parsers'

include Dolos

# Include common parsers
# In future this can be more structured, moved them to separate module to prevent breaking changes
include Dolos::CommonParsers

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
name_line = ws.rep0 & honorific & first_name & ws & last_name & eol

# Next line is company info
# We could choose to accept UAB and AB or just AB and etc.
# 'c("AB")' is for case-sensitive string. 'string' can also be used
company_type = c("AB")
quote_open = c("„")
quote_close = c("“")

# Consume LT alphabet with whitespace
company_name = (alpha_with_lt | ws).rep.map(&:join).capture!
company_info = company_type & ws.rep0 & quote_open & company_name & quote_close
second_line = ws.rep0 & company_info & eol

# Address line
# 'char_while' will consume characters while passed predicate is true
# This could be an alternative to previous 'alpha_with_lt' approach
# After that result is captured and mapped to hash
# Mapping to hash so at the end its easy to tell tuples apart
# Also while mapping, doing some cleaning with '.strip'
street_name = char_while(->(char) { !char.match(/\d/) }).map { |s| { street: s.strip } }.capture!
building = digits.map { |s| { building: s.strip } }.capture!
address_line = ws.rep0 & street_name & building & eol

# City line
# All digits can be matched here or 'digits.rep(5)' could be used. Also joining with map.
postcode = digits.map { |s| { postcode: s.strip } }.capture!
city = alpha_with_lt.rep.map(&:join).map { |s| { city: s.strip } }.capture!
city_line = ws.rep0 & postcode & ws & city & eol

# Full letter parser which is combined from all previous parsers. All previous parsers can be ran separately.
letter_parser = name_line & second_line & address_line & city_line
result = letter_parser.run(letter)

pp result.captures

```
### Roadmap
- Better error handling
- Benchmarks & parser tests
- Documentation
- Performance

### Benchmarks
`bundle exec ruby benchmarks/json/json.rb`
```
Dolos
nested json benchmark      8.426  (± 0.0%) i/s -     43.000  in   5.103600s
letter benchmark           3.145k (± 0.7%) i/s -     15.810k in   5.027961s

# Note: 23 times slower than Pure Ruby specialized json parser (below) if used to parse json
nested json 166KB bench    8.189  (± 0.0%) i/s -     41.000  in   5.007158s
nested json 1MB bench      0.959  (± 0.0%) i/s -     5.000  in    5.230650s

-----------------------------------------------------------
Pure ruby (flori/json)
nested json 1MB bench      24.213  (± 4.1%) i/s -    122.000  in   5.042309s
nested json 166KB bench   188.070  (± 1.6%) i/s -    954.000  in   5.073788s
Ruby native (C)
nested json 1MB bench     309.519  (± 0.3%) i/s -    1.560k in    5.040164s
```

### Contributing
Contributors are welcome. Note: since library is not yet stable, I recommend getting in touch with me before starting to work on something.

#### Other parser combinator libraries
- [Fastparse](https://com-lihaoyi.github.io/fastparse/) (Scala)
- [Parsby](https://github.com/jolmg/parsby) (Ruby)