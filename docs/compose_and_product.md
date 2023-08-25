# Compose and product

The Dolos library allows for parser composition using product operators. 
These operators help you build more complex parsers by combining simpler ones.
Understanding how these operators work is crucial to leverage the full power of the library.

## Right Arrow: `product_r` or `>>`

The right arrow (>>) operator combines two parsers and discards the result of the first parser, keeping the result of the second parser.

```ruby
first_parser = c("Hello")
second_parser = digits

combined_parser = first_parser >> second_parser

result = combined_parser.run("Hello123")
puts result.inspect # => Success(value: '123', length: 8, captures: '[]')
```
In this example, the combined_parser expects "Hello" followed by digits. It returns only the digits as its value.

## Left Arrow: `product_l` or `<<`

The left arrow (<<) operator combines two parsers and discards the result of the second parser, keeping the result of the first one.

```ruby
first_parser = c("Hello")
second_parser = digits

combined_parser = first_parser << second_parser

result = combined_parser.run("Hello123")
puts result.inspect # => Success(value: 'Hello', length: 8, captures: '[]')
```
Here, the combined_parser still expects "Hello" followed by digits, but it returns only "Hello" as its value.

## Ampersand: `product` or `&`

The ampersand (&) operator combines the results of both parsers into an array.

```ruby
first_parser = c("Hello")
second_parser = digits

combined_parser = first_parser & second_parser

result = combined_parser.run("Hello123")
puts result.inspect # => Success(value: ['Hello', '123'], length: 8, captures: '[]')
```
This time, combined_parser returns both "Hello" and "123" as its value in an array.

Aliases:
- `&` is aliased as `.product`

- `>>` is aliased as `.product_r`

- `<<` is aliased as `.product_l`

## Combining More Than Two Parsers

You can chain these operators to combine more than two parsers.

```ruby
hello = c("Hello")
space = c(" ")
name = char_while(->(char) { char.match?(/[a-zA-Z]/) })

combined_parser = hello >> space & name

result = combined_parser.run("Hello Alice")
puts result.inspect # => Success(value: [' ', 'Alice'], length: 11, captures: '[]')
```