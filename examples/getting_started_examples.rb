require 'dolos'

include Dolos
include Dolos::Common

def todo_comment
  todo_flag = c("# TODO: ")

  # Capture all characters until new line symbol
  task = char_while(->(char) { char != "\n" })

  # Compose and return what's parsed by task
  todo_comment = todo_flag >> task

  result = todo_comment.run("# TODO: Write a blog post about Dolos")
  puts result.inspect # => Success(value: 'Write a blog post about Dolos',length: 0, captures: '[]')
end

def temperature_humid_value
  input = "Temperature: 21 C, Humidity: 50 %"

  # Map string to integer
  digits_as_ints = digits.map(&:to_i)

  # Temperature parser will return an integer
  # `>>` and `<<` helps to discard non-used values
  temp_prefix = c("Temperature:") >> ws_rep0
  temp_suffix = ws_rep0 >> c("C")
  temp = (temp_prefix >> digits_as_ints << temp_suffix).map { |t| { temp: t } }

  hum_prefix = c("Humidity:") >> ws_rep0
  hum_suffix = ws_rep0 >> c("%")
  humidity = (hum_prefix >> digits_as_ints << hum_suffix).map { |h| { humid: h } }

  # Will need to use product operator `&`, because it doesn't discard either side
  parser = temp << ws_rep0 << c(",") << ws_rep0 & humidity
  result = parser.run(input)

  # Result is a tuple of two integers
  puts result.inspect # => Success(value: '[{:temp=>21}, {:humid=>50}]',length: 1, captures: '[]')
end

def temperature_humid_capture
  input = "Temperature: 21 C, Humidity: 50 %"

  # Map string to integer
  digits_as_ints = digits.map(&:to_i)

  # Temperature parser will return an integer
  # `>>` and `<<` helps to discard non-used values
  temp_prefix = c("Temperature:") >> ws_rep0
  temp_suffix = ws_rep0 >> c("C")
  temp = (temp_prefix >> digits_as_ints.capture! >> temp_suffix).map_captures { |t| { temp: t } }

  hum_prefix = c("Humidity:") >> ws_rep0
  hum_suffix = ws_rep0 >> c("%")
  humidity = (hum_prefix >> digits_as_ints.capture! >> hum_suffix).map_captures { |h| { humid: h } }

  # Will need to use product operator `&`, because it doesn't discard either side
  parser = temp >> ws_rep0 >> c(",") >> ws_rep0 & humidity
  result = parser.run(input)

  # Result is a flat captures array
  puts result.inspect # => Success(value: '[" ", "%"]',length: 1, captures: '[{:temp=>[21]}, {:humid=>[50]}]')
end
