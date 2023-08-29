## String parser: `string("")` ir `c("")`

Will match a string exactly as written. For example, `string("Hello")` will match the string "Hello".
`c("hello")` is a shorthand for `string("hello")`. It can be read as `case-sensitive` string

```ruby
parser = string("Hello")
result = parser.run("Hello")
puts result.success?  # => true
puts result.value  # => "Hello"
```

Output of parser will be the value of the string. In this case, "Hello".

## Any character parser: `any_char`

Will match any character. For example, `any_char` will match "a", "b", "c", "1", "2", "3", etc.

```ruby
parser = any_char
result = parser.run("a")
puts result.success?  # => true
```

## Characters in set: `char_in('abc')`

Will match any character in the given set. For example, `char_in('abc')` will match "a", "b", or "c".

```ruby
parser = char_in('abc')
result = parser.run("a")
puts result.success?  # => true
```

## Characters While Parser: `char_while(predicate)`

Matches a sequence of characters until given predicate returns false. For example, `char_while(->(c) { c != '\n'})` will match any character until it encounters a newline.

```ruby
parser = char_while(->(c) { c != '\n'})
result = parser.run("123abc\n321")
puts result.success?  # => true
puts result.value  # => "123abc"

```

## Regex parser: `regex(/regex/)`

Will match a regular expression. For example, `regex(/a+/)` will match "a", "aa", "aaa", etc.

```ruby
parser = regex(/a+/)
result = parser.run("aaa")
puts result.success?  # => true
puts result.value  # => "aaa"
```