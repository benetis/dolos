# frozen_string_literal: true

require 'dolos_common_parsers/common_parsers'
RSpec.describe 'parse json' do
  include Dolos
  include Dolos::CommonParsers

  describe 'json' do
    let(:ws_rep0) { ws.rep0 }
    let(:comma) { c(",") }
    let(:string_literal) do
      (c("\"") >> char_while(->(ch) { ch != "\"" }) << c("\""))
    end

    let(:value) do
      digit | object | string_literal
    end

    let(:key_line) do
      ((string_literal << ws_rep0) << c(":") & ws_rep0 >> value).map_value do |tuple|
        {tuple[0] => tuple[1]}
      end
    end

    let(:key_lines) do
      (key_line << ws_rep0).repeat(n_min: 1, separator: (comma << ws_rep0)).map_value do |arr|
        arr.reduce({}) do |acc, hash|
          acc.merge(hash)
        end
      end
    end


    let(:object) do
      recursive do |obj|
        c("{") >> ws_rep0 >> key_lines.opt << ws_rep0 << c("}")
      end
    end

    let(:json_parser) do
      value
    end

    context 'when basic scenarios without recursion' do
      it 'captures empty object' do
        json = '{}'

        result = json_parser.run(json)
        expect(result.success?).to be_truthy
      end

      it 'parses successfully a name and value in object' do
        json = '{ "key": 1 }'
        result = json_parser.run(json)
        expect(result.success?).to be_truthy
        expect(result.value).to eq({ "key" => "1" })
      end

      it 'supports multiple keys' do
        json = '{ "key": 1, "key2": 2 }'
        result = json_parser.run(json)
        expect(result.success?).to be_truthy
        expect(result.value).to eq({ "key" => "1", "key2" => "2" })
      end
    end

    context 'when recursive' do
      it 'parses an object inside object' do
        json = '{ "key": { "key2": 1 } }'

        result = json_parser.run(json)

        expect(result.success?).to be_truthy
        expect(result.value).to eq({ "key" => { "key2" => "1" } })
      end

      it 'parse an object inside object inside object' do
        json = '{ "key": { "key2": { "key3": 1 } } }'

        result = json_parser.run(json)

        expect(result.success?).to be_truthy
        expect(result.value).to eq({ "key" => { "key2" => { "key3" => "1" } } })
      end

      it 'parses multiple keys inside nested objects' do
        json = '{ "key": { "key2": 1, "key3": 2 } }'

        result = json_parser.run(json)

        expect(result.success?).to be_truthy
        expect(result.value).to eq({ "key" => { "key2" => "1", "key3" => "2" } })
      end
    end

  end
end