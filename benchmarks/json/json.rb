# frozen_string_literal: true

require 'benchmark/ips'
require 'bundler/setup'
require 'dolos'
require 'dolos_common_parsers/common_parsers'

include Dolos
include Dolos::CommonParsers
def comma = c(",")

def string_literal = (c("\"") >> char_while(->(ch) { ch != "\"" }).opt << c("\""))

def boolean = (c("true").map { true } | c("false").map { false })

def null = c("null").map { nil }

def array = recursive do |arr|
  c("[") >> ws_rep0 >> value.repeat(n_min: 0, separator: (comma << ws_rep0)) << ws_rep0 << c("]")
end

def negative_sign = c("-").opt

def decimal_point = c('.').opt

def number = (negative_sign & digits & decimal_point & digits.opt).map do |tuple|
  tuple.join.to_f
end

def value = number | object | string_literal | boolean | null | array

def key_line = ((string_literal << ws_rep0) << c(":") & ws_rep0 >> value).map do |tuple|
  { tuple[0] => tuple[1] }
end

def key_lines = (key_line << ws_rep0).repeat(n_min: 1, separator: (comma << ws_rep0 << eol.opt)).map do |arr|
  arr.reduce({}) do |acc, hash|
    acc.merge(hash)
  end
end

def object = recursive do |obj|
  c("{") >> ws_rep0 >> key_lines.opt << ws_rep0 << c("}")
end

def json_parser = ws_rep0 >> value

json_from_file = File.read('benchmarks/json/nested_json.json')

result = json_parser.run(json_from_file)
puts result.success?

Benchmark.ips do |x|
  x.report('nested json benchmark') do
    json_parser.run(json_from_file)
  end
  x.compare!
end
