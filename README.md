# Dolos

<img height="256" src="docs/dolos_stable_diff.png" width="256"/>


### Disclaimer
🚧 Under development, not stable yet 🚧

### Parser combinator library for Ruby

It does not use exceptions and instead returns a result object.
Library is composable and concise.

```ruby
include Dolos

parser = c("Parsers") >> ws >> c("are") >> ws >> c("great!")
parser.parse("Parsers are great!") # <Result::Success>

greeter = c("Hello")
greet_and_speak = greeter >> c(", ") >> parser
greet_and_speak.parse("Hello, Parsers are great!") # <Result::Success>
```
