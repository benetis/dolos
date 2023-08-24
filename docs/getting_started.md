# Getting started 

## Installation

Install the gem and add it to your Gemfile:
```shell
$ bundle add dolos
```
Or manually:
```ruby
gem 'dolos'
```

## Usage

Two things to do:
- require library
- include module `Dolos` and `Dolos::Common`

```ruby
require 'dolos'

include Dolos
include Dolos::Common # Common parsers
```

### 'One word' parser

Let's say you want to validate if input is equal to a specific word.
A simple parser which matches one word.

```ruby
require 'dolos'
include Dolos

hello = c("Hello") # c("") is an alias for string(""). Can be read as: case-sensitive string match

hello.run("Hello").success? # => true

hello.run("hello").success? # => failure
```

After defining parser, it can be ran with `run('my-input')` method. It returns a `Result` object.

#### Result

Result can be either `Success` or `Failure`. It can be checked with `success?` or `failure?` methods.

Success will also have `value` property which will contain the result of the parser. There is also `captures`, but
that's for later.
```ruby
hello.run("Hello").inspect # => Success(value: 'Hello',length: 5, captures: '[]')
```

Failure will have `inspect` method which will return a string with the error message. It will show error position as well.

### Compose parsers

> All examples can be found in [examples/getting_started](https://github.com/benetis/dolos/blob/master/examples/getting_started_examples.rb)

You have a parser you wrote before which parses hello.
Now you want to parse a greeting which is hello followed by a name.

```ruby

hello = c("Hello")
greeting = hello >> c(" ") >> c("stargazer")

greeting.run("Hello stargazer").success? # => true
```

Resulted `greeting` is a new parser which was composed of those 3 parsers

`>>` is a compose operator, discards value on the left.
There is also `<<` and `&`. `&` keeps both values.

### Capture text with parsers

Let's write a parser which parses TODO comment lines.

```ruby
todo_flag = c("# TODO: ")

# Capture all characters until new line symbol
task = char_while(->(char) { char != "\n" })

# Compose and return what's parsed by task
todo_comment = todo_flag >> task

result = todo_comment.run("# TODO: Write a blog post about Dolos")
puts result.inspect # => Success(value: 'Write a blog post about Dolos',length: 0, captures: '[]')
```

### Capture results and transform them with `.map`

#### Capturing a value (with `>>` and so on)

Parse temperature and humidity from a string. Let's assume there can be whitespaces and etc.
Let's get the result as value.

```ruby
input = "Temperature: 21 C, Humidity: 50 %"

# Map string to integer
digits_as_ints = digits.map(&:to_i)

# Temperature parser will return an integer
# `>>` and `<<` helps to discard non-used values
temp_prefix = c("Temperature:") >> ws_rep0
temp_suffix = ws_rep0 >> c("C")
temp = (temp_prefix >> digits_as_ints << temp_suffix)

hum_prefix = c("Humidity:") >> ws_rep0
hum_suffix = ws_rep0 >> c("%")
humidity = (hum_prefix >> digits_as_ints << hum_suffix)

# Will need to use product operator `&`, because it doesn't discard either side
parser = temp << ws_rep0 << c(",") << ws_rep0 & humidity
result = parser.run(input)

# Result is a tuple of two integers
puts result.inspect # => Success(value: [21, 50],length: 0, captures: '[]')
```

#### Using hash to name results

Resulting tuple is a bit hard to understand. Let's use `map` to transform it to a hash.
We can do this near the temperature and humidity parser, before all the composition.

```ruby
temp = (temp_prefix >> digits_as_ints << temp_suffix).map { |t| { temp: t } }
humidity = (hum_prefix >> digits_as_ints << hum_suffix).map { |h| { humid: h } }

This will result in:
# => Success(value: '[{:temp=>21}, {:humid=>50}]',length: 1, captures: '[]')
```

Much better. But all this `>>` and `<<` and `&` _nonsense_ to get the wanted results can be avoided as well. At least, for simple parsers ;)

#### Using `.capture!`

Everything is very similar. Just instead of different product operators, we can use one and use `capture!`.
We will ignore resulting value,`capture!` will store captured results in `.captures` array on `Result`.

Same temperature example:

```ruby
temp_prefix = c("Temperature:") >> ws_rep0
temp_suffix = ws_rep0 >> c("C")

# Immediately capture result and map with `map_captures`
temp = (temp_prefix >> digits_as_ints.capture! >> temp_suffix).map_captures { |t| { temp: t } }

hum_prefix = c("Humidity:") >> ws_rep0
hum_suffix = ws_rep0 >> c("%")
humidity = (hum_prefix >> digits_as_ints.capture! >> hum_suffix).map_captures { |h| { humid: h } }

parser = temp >> ws_rep0 >> c(",") >> ws_rep0 & humidity
result = parser.run(input)

# Result is a flat captures array
# Value will be nonsense, but we are interested in `.captures`
# => Success(value: '[" ", "%"]',length: 1, captures: '[{:temp=>[21]}, {:humid=>[50]}]')
puts result.inspect
```

Note on this: You will want to name your captures with `.map_captures` as otherwise it will be hard to understand what's what.
