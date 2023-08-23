# Dolos

## What is Dolos?
Dolos is parser combinator library for Ruby. It is inspired by FastParse and Scala Parser Combinators.

## What are parser combinators?
Parser combinators are a way to build parsers from smaller parsers. For example, you can build a parser for a number from a parser for a digit.
This is a very simple example, but it can be used to build more complex parsers.
Parsers are lazy and only run when needed. This allows to build complex parsers before passing input to them.
```ruby
hello = string("Hello")
greeting = hello >> c(" ") >> string("Ruby developer!")
greeting.run("Hello Ruby developer!") # => Success
```

## What's different from alternatives?
This library focuses on two things:
- Parsers integrate well into Ruby code. There is no need to keep them in separate classes.
- Fine grained control over parsers. You can `map` and adjust each parser separately
- Two ways of capturing values: traditional `>>`, other product operators to construct value and `capture!`
  - For simple parsers `capture!` can be used to very quickly capture values into flat arrays 
- Running parsers will not throw exceptions and instead return a result object. Exceptions don't play well with parsing.