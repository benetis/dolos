# Choice and optional

## Choice Operator: `choice` or `|`
The choice operator provides a way to select among multiple parsers. 
If the first parser fails, the second parser is tried, and so on.

```ruby
first_parser | second_parser

# or you can use it like:

first_parser.choice(second_parser)
```

Let's say you want to parse either the word "dog" or "cat".

```ruby
animal = c("dog") | c("cat")
result1 = animal.run("dog")
result2 = animal.run("cat")
result3 = animal.run("fish")

puts result1.success?  # => true
puts result2.success?  # => true
puts result3.success?  # => false
```
In this example, animal will be a new parser that tries to parse "dog" first. 
If it fails, it will try to parse "cat".

#### Result

The result of choice will be the Success object for the first successful parser in the chain.

## Optional Operator: `optional` or `opt`

The optional method, also aliased as opt, makes the parser optional. 
This means that the parser will succeed whether or not the pattern is found.

```ruby
parser.optional

# or you can use the alias:

parser.opt

```

Let's say you have an optional space after a colon in a key-value pair string like "key:value ".

```ruby
key = c("key")
separator = c(":")
space = c(" ").opt

key_value = key >> separator >> space

result1 = key_value.run("key:")
result2 = key_value.run("key: ")

puts result1.success?  # => true
puts result2.success?  # => true
```
In this example, key_value will be a new parser that successfully parses whether or not there is a space after the colon.

#### Result

The result of optional will be a Success object with an empty array as its value if the parser fails. 
If the parser succeeds, it will return the successful Result as usual.