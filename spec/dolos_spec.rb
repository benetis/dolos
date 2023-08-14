# frozen_string_literal: true

RSpec.describe Dolos do
  include Dolos
  describe 'run' do

    it 'should match a string and return success' do
      parser = string('hello')
      result = parser.run('hello')

      expect(result.success?).to be_truthy
    end
  end

  describe 'product' do

    it 'should combine two parsers' do
      parser = string('hello') >> string('world')
      result = parser.run('helloworld')


      pp result
      expect(result.success?).to be_truthy
    end

  end

end
