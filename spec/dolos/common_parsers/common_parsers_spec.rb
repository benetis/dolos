# frozen_string_literal: true
require 'dolos_common_parsers/common_parsers'

RSpec.describe Dolos::CommonParsers do
  include Dolos
  include Dolos::CommonParsers

  describe 'ws' do
    it 'parses whitespace' do
      parser = ws
      result = parser.run(' ')

      expect(result.success?).to be_truthy
    end
  end

end
