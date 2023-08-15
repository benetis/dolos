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
  let(:first_name) { alpha_with_lt.rep.capture!.map(&:join) }
  let(:last_name) { alpha_with_lt.rep.capture!.map(&:join) }
  let(:first_line) { ws.rep0 >> honorific >> first_name >> ws >> last_name >> eol }

  let(:company_type) { c("AB") }
  let(:quote_open) { c("„") }
  let(:quote_close) { c("“") }
  let(:company_name) { (alpha_with_lt | ws).rep.capture!.map(&:join) }
  let(:company_info) { company_type >> ws.rep0 >> quote_open >> company_name >> quote_close }
  let(:second_line) { ws.rep0 >> company_info >> eol }

  context 'first line' do
    it 'captures first and last name' do
      result = first_line.run(letter)

      expect(result.success?).to be_truthy
      expect(result.captures).to eq(["Vardeniui", "Pavardeniui"])
    end
  end

  context 'second line' do
    it 'captures company name' do
      both_lines = first_line >> second_line
      result = both_lines.run(letter)

      expect(result.success?).to be_truthy
      expect(result.captures).to eq(["Vardeniui", "Pavardeniui", "Lietuvos Paštas"])
    end
  end

end