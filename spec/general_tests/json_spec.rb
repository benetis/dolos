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
    let(:boolean) do
      (c("true").map_value { true } | c("false").map_value { false })
    end
    let(:null) do
      c("null").map_value { nil }
    end
    let(:array) do
      recursive do |arr|
        c("[") >> ws_rep0 >> value.repeat(n_min: 0, separator: (comma << ws_rep0)) << ws_rep0 << c("]")
      end
    end

    let(:value) do
      digit | object | string_literal | boolean | null | array
    end

    let(:key_line) do
      ((string_literal << ws_rep0) << c(":") & ws_rep0 >> value).map_value do |tuple|
        { tuple[0] => tuple[1] }
      end
    end

    let(:key_lines) do
      (key_line << ws_rep0).repeat(n_min: 1, separator: (comma << ws_rep0 << eol.opt)).map_value do |arr|
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
      ws_rep0 >> value
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

      it 'supports string literals as values' do
        json = '{ "key": "value" }'
        result = json_parser.run(json)
        expect(result.success?).to be_truthy
        expect(result.value).to eq({ "key" => "value" })
      end

      it 'supports boolean literals as values' do
        json = '{ "key": true }'
        result = json_parser.run(json)
        expect(result.success?).to be_truthy
        expect(result.value).to eq({ "key" => "true" })
      end

      it 'supports null literals as values' do
        json = '{ "key": null }'
        result = json_parser.run(json)
        expect(result.success?).to be_truthy
        expect(result.value).to eq({ "key" => "null" })
      end

      it 'supports multiline jsons' do
        json = <<-JSON
        {
          "key": 1,
          "key2": 2,
          "key3": 3
        }
        JSON
        result = json_parser.run(json)
        expect(result.success?).to be_truthy
        expect(result.value).to eq({ "key" => "1", "key2" => "2", "key3" => "3" })
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

      it 'parses nested objects inside arrays' do
        json = '[{ "key": { "key2": 1 } }]'

        result = json_parser.run(json)

        expect(result.success?).to be_truthy
        expect(result.value).to eq([{ "key" => { "key2" => "1" } }])
      end
    end

    context 'when dealing with arrays' do
      it 'parses an empty array' do
        json = '[]'
        result = json_parser.run(json)
        expect(result.success?).to be_truthy
        expect(result.value).to eq([])
      end

      it 'parses an array with values' do
        json = '[1, "string", true]'
        result = json_parser.run(json)
        expect(result.success?).to be_truthy
        expect(result.value).to eq(["1", "string", "true"])
      end

      it 'parses nested arrays' do
        json = '[1, [2, 3], ["a", "b"]]'
        result = json_parser.run(json)
        expect(result.success?).to be_truthy
        expect(result.value).to eq(["1", ["2", "3"], ["a", "b"]])
      end

      it 'parses arrays inside objects' do
        json = '{ "key": [1, 2, 3] }'
        result = json_parser.run(json)
        expect(result.success?).to be_truthy
        expect(result.value).to eq({ "key" => ["1", "2", "3"] })
      end
    end

    context 'when ruby transformations' do
      it 'converts "null" to nil' do
        json = '{ "key": null }'
        result = json_parser.run(json)
        expect(result.success?).to be_truthy
        expect(result.value).to eq({ "key" => nil })
      end

      it 'converts "true" to true' do
        json = '{ "key": true }'
        result = json_parser.run(json)
        expect(result.success?).to be_truthy
        expect(result.value).to eq({ "key" => true })
      end

      it 'converts "false" to false' do
        json = '{ "key": false }'
        result = json_parser.run(json)
        expect(result.success?).to be_truthy
        expect(result.value).to eq({ "key" => false })
      end

      it 'does not convert "true" inside a string to true' do
        json = '{ "key": "true" }'
        result = json_parser.run(json)
        expect(result.success?).to be_truthy
        expect(result.value).to eq({ "key" => "true" })
      end

    end

    context 'random examples' do
      it 'parses badly formatted vscode settings excerpt' do
        json = <<-JSON
        {            "files.watcherExclude": {            "**/.bloop": true,
            "**/.metals": true,
            "**/.ammonite": true,            "**/.history": true
          }
        }
        JSON
        result = json_parser.run(json)
        expect(result.success?).to be_truthy
        expect(result.value).to eq({
                                     "files.watcherExclude" => {
                                       "**/.bloop" => true,
                                       "**/.metals" => true,
                                       "**/.ammonite" => true,
                                       "**/.history" => true, }
                                   })
      end
    end

  end
end