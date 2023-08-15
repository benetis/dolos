# frozen_string_literal: true

RSpec.describe Dolos do
  include Dolos

  describe 'choice' do
    it 'matches the first parser' do
      parser = string('hello') | string('world')
      result = parser.run('hello')

      expect(result.success?).to be_truthy
    end

    it 'matches the second parser' do
      parser = string('hello') | string('world')
      result = parser.run('world')

      expect(result.success?).to be_truthy
    end

    it 'returns failure if nothing matches' do
      parser = string('hello') | string('world')
      result = parser.run('!')

      expect(result.failure?).to be_truthy
    end

    it 'handles failing parser before success and continues' do
      parser = (string('hello') | string('world') | string('!')) >> string(" the ") >> string('end') | string('beginning')
      result = parser.run('! the beginning')

      expect(result.success?).to be_truthy
    end

    context 'captures' do
      it 'captures the result of the first parser' do
        parser = string('hello').capture! | string('world')
        result = parser.run('hello')

        expect(result.captures).to eq(['hello'])
      end

      it 'captures the result of the second parser' do
        parser = string('hello') | string('world').capture!
        result = parser.run('world')

        expect(result.captures).to eq(['world'])
      end

      it 'captures groups' do
        parser = (string('hello') | string('world')).capture!
        result = parser.run('world')

        expect(result.captures).to eq(['world'])
      end
    end
  end

end