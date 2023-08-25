# Map and capture

## Two ways to capture outputs

You can get your results in two ways:
- `.value` – will return the result of the parser. You have to use various product operators to get the result you want.
It the most powerful and you can write any parser you want. However, it might be a bit of a hassle in complex parsers.
To map value, you can use `.map` method.
- `.captures` – will return the result of the parser. 
It will be a flattened array of all captures. You can use `.capture!` to capture results in sequence. 
If no parser is captured – result will be empty. To map captures, you can use `.map_captures` method.

## `map`
The map method allows you to transform the successful result of a parser into another value.

```ruby
parser.map { |result| ... }
```

For example, if you want to convert the result of parsing digits into an integer:

```ruby
# digits is a common parser which takes all digits with d+ match

integers = digits.map { |d| d.to_i }

result = integers.run("123")

puts result.value  # => 123
```
In this example, integer will be a new parser that runs the digits parser and then converts the result into an integer.

#### Result

The map method returns a new parser that, upon success, contains the mapped value.

## `.capture!`

Another way to transform the result of a parser is to capture the result.
Instead of using different product to output the needed parser result – we can short circuit the process and use `.capture!` method.
Whatever is captured, will be stored in `.captures` flattened array on `Result`.
This mean that if you have nested captures, they will be flattened, it is a limitation of this method. But for most cases – you don't need nested structures.

```ruby
parser = string('hello').capture!
result = parser.run('hello')

# result.captures will contain ['hello']
```

#### Capture multiple parsers

```ruby
parser = (string('hello') & string('world')).capture!
result = parser.run('helloworld')

puts result.captures# => will contain ['hello', 'world']
```

#### Capture results in sequence
```ruby
loud_hello = (string('hello') & string('world')).capture!
parser = loud_hello & string('!') & string('!')

result = parser.run('helloworld!!')
puts result.captures # will contain ['hello', 'world']
```

### Name your captures

Since `.captures` is a flattened array, it might be hard to understand what is what.
For example, this is the result from letter example: 
```ruby
# => ["Vardeniui", "Pavardeniui", "Lietuvos Paštas", {:street=>"Totorių g."}, {:building=>"8"}, {:postcode=>"01121"}, {:city=>"Vilnius"}]
```
If it wasn't marked with hashes – it would be hard to tell what is what.

#### `.capture!(wrap_in)`

There is a helper method to wrap captures in a hash with a given key.
You can achieve the same result with `.map_captures`

```ruby
parser = string('hello').capture!(:hallo)
result = parser.run('hello')

# result.captures will contain [{:hallo => 'hello'}]
```

### `.map_captures`

This method is similar to `.map` but it will map `.captures` array instead of `.value`.
It will return a new parser that, upon success, contains the mapped value.

Note: this will map over the array of captures, not one value. You might need to use `.map` inside map_captures to map over each capture.

```ruby
parser = string('hello').capture!.map_captures { |all_captures| all_captures.map(&:upcase) }
result = parser.run('hello') 
puts result.captures # => ['HELLO']
```
