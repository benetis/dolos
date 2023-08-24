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
hello.run("Hello").inspect # => Success(value: 'Hello',length: 5, capture: '[]')
```

Failure will have `inspect` method which will return a string with the error message. It will show error position as well.

[Normalize numbers](normalize_numbers.md ':include')