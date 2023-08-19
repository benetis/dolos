# frozen_string_literal: true

require 'dolos_common_parsers/common_parsers'
RSpec.describe 'should parse address on a letter' do
  include Dolos
  include Dolos::CommonParsers

  let(:letter) { <<-LETTER
        Mr. Vardeniui Pavardeniui
        AB „Lietuvos Paštas“
        Totorių g. 8
        01121 Vilnius
  LETTER
  }
  let(:honorific) { c("Mr. ") | c("Mrs. ") | c("Ms. ") }
  let(:alpha_with_lt) { char_in("ąčęėįšųūžĄČĘĖĮŠŲŪŽ") | alpha }
  let(:first_name) { alpha_with_lt.rep.map(&:join).capture! }
  let(:last_name) { alpha_with_lt.rep.map(&:join).capture! }
  let(:name_line) { ws.rep0 & honorific & first_name & ws & last_name & eol }

  let(:company_type) { c("AB") }
  let(:quote_open) { c("„") }
  let(:quote_close) { c("“") }
  let(:company_name) { (alpha_with_lt | ws).rep.map(&:join).capture! }
  let(:company_info) { company_type & ws.rep0 & quote_open & company_name & quote_close }
  let(:second_line) { ws.rep0 & company_info & eol }

  let(:street_name) { char_while(->(char) { !char.match(/\d/) }).map { |s| { street: s.strip } }.capture! }
  let(:building) { digits.map { |s| { building: s.strip } }.capture! }
  let(:address_line) { ws.rep0 & street_name & building & eol }

  let(:postcode) { digits.map { |s| { postcode: s.strip } }.capture! }
  let(:city) { alpha_with_lt.rep.map(&:join).map { |s| { city: s.strip } }.capture! }
  let(:city_line) { ws.rep0 & postcode & ws & city & eol }

  context 'first line' do
    it 'captures first and last name' do
      result = name_line.run(letter)

      expect(result.success?).to be_truthy
      expect(result.captures).to eq(["Vardeniui", "Pavardeniui"])
    end
  end

  context 'second line' do
    it 'captures company name' do
      both_lines = name_line & second_line
      result = both_lines.run(letter)

      expect(result.success?).to be_truthy
      expect(result.captures.last).to eq("Lietuvos Paštas")
    end
  end

  context 'third line' do
    it 'captures street name and number' do
      three_lines = name_line & second_line & address_line
      result = three_lines.run(letter)

      expect(result.success?).to be_truthy
      expect(result.captures.last(2)).to eq([{ :street => "Totorių g." }, { :building => "8" }])
    end
  end

  context 'fourth line' do
    it 'captures postcode and city' do
      four_lines = name_line & second_line & address_line & city_line
      result = four_lines.run(letter)

      expect(result.success?).to be_truthy
      expect(result.captures.last(2)).to eq([{:postcode=>"01121"}, {:city=>"Vilnius"}])
    end
  end

end