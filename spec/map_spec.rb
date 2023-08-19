# frozen_string_literal: true

RSpec.describe Dolos do
  include Dolos

  describe 'map_value' do
    it 'maps over one parser' do
      parser = string('hello').map_value { |value| value.upcase }
      result = parser.run('hello')

      expect(result.value).to eq('HELLO')
    end

    it 'maps over two parsers' do
      parser = (string('hello') & string('world')).map_value { |value| value.map(&:upcase) }
      result = parser.run('helloworld')

      expect(result.value).to eq(['HELLO', 'WORLD'])
    end

    it 'maps over two parsers and uses them in a third' do
      loud_hello = (string('hello') & string('world')).map_value { |value| value.map(&:upcase) }

      parser = loud_hello & string('!')

      result = parser.run('helloworld!')
      expect(result.value.flatten).to eq(['HELLO', 'WORLD', '!'])
    end
  end

  describe 'map_captures' do
    it 'maps over parsers and converts them to ints' do
      parser = (string("1") & string("2") & string("3")).capture!.flatten.map_captures { |value| value.map(&:to_i) }

      result = parser.run("123")
      expect(result.captures).to eq([1, 2, 3])
    end

    it 'maps over groups and converts to ints' do
      first = (string("1") & string("2")).capture!.map_captures { |value| value.map(&:to_i) }
      second = (string("3") & string("4")).capture!.map_captures { |value| value.map(&:to_i) }
      parser = (first & second)

      result = parser.run("1234")
      expect(result.captures).to eq([1, 2, 3, 4])
    end

    it 'maps over groups to add and then multiply' do
      first = (string("1") & string("2")).capture!.map_captures { |digit| digit.map(&:to_i).reduce(:+) } # 3
      second = (string("3") & string("4")).capture!.map_captures { |digit| digit.map(&:to_i).reduce(:+) } # 7
      parser = (first & second).map_captures { |value| value.reduce(:*) } # 21

      result = parser.run("1234")
      expect(result.captures).to eq(21)
    end
  end

  describe 'map' do
    it 'maps both values and captures' do
      parser = (string("1") & string("2")).capture!.map { |value| value.map(&:to_i) }

      result = parser.run("12")
      expect(result.captures).to eq([1, 2])
      expect(result.value).to eq([1, 2])
    end
  end

end