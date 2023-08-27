# Repeat
## Overview

The repeat method in the Dolos parsing library is designed to execute a parser multiple times based on the specified minimum and maximum repetitions. 
You can also optionally include a separator parser to run between each repetition. 
The method allows you to express different repetition needs effectively

## Aliases

- Zero or more times: `rep0`
- One or more times: `rep`
- Exactly n times: `rep(n)`
- Between n_min and n_max times: `repeat(n_min, n_max)`
- Another parser as separator: `repeat(n_min, n_max, separator_parser)`

#### Zero or more times: `rep0`

The `rep0` alias allows the parser to match zero or more times. 
This is useful when the occurrence of a pattern is optional or can be repeated multiple times in a sequence.

```ruby
parser = c('a').rep0
result = parser.run('aaa')
puts result.value  # => ['a', 'a', 'a']

result2 = parser.run('bbb')
puts result2.value  # => []
```
In this example, the parser matches the character 'a' zero or more times, returning an array of matched 'a's.

#### One or more times: `rep`

The rep alias will attempt to match the parser one or more times.
This is useful when you expect at least one occurrence of a pattern.

```ruby
parser = c('a').rep
result = parser.run('aaa')
puts result.value  # => ['a', 'a', 'a']

result2 = parser.run('bbb')
puts result2.success?  # => false
```

#### Exactly n times: `rep(n)`

This allows you to specify the exact number of times the parser should match.

```ruby
parser = c('a').rep(3) << c('b')
result = parser.run('aaab')
puts result.value  # => ['a', 'a', 'a']

result2 = parser.run('aaaab')
puts result2.success?  # => false
```

#### Between n_min and n_max times: `repeat(n_min, n_max)`

Here, you can specify both the minimum (n_min) and the maximum (n_max) number of times the parser should match.

```ruby
parser = c('a').repeat(n_min: 2, n_max: 4)
result = parser.run('aaa')
puts result.value  # => ['a', 'a', 'a']
```

The parser will match between 2 to 4 occurrences of 'a' in the input.
#### Another parser as separator: `repeat(n_min, n_max, separator_parser)`

You can specify a separator_parser that will match between each repetition of the main parser.

```ruby
parser = c('a').repeat(n_min: 2, n_max: 3, separator: c(','))
result = parser.run('a,a')
puts result.value  # => ['a', 'a']
```
