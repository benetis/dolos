# frozen_string_literal: true

RSpec.describe Dolos do
  include Dolos


  describe 'optional' do
    it 'matches' do
      parser = string('hello').optional
      result = parser.run('hello')

      expect(result.success?).to be_truthy
      expect(result.value).to eq('hello')
    end

    it 'does not match' do
      parser = string('hello').optional
      result = parser.run('')

      expect(result.success?).to be_truthy
      expect(result.value).to eq([])
    end

    it 'captures' do
      parser = string('hello').optional.capture!
      result = parser.run('hello')

      expect(result.captures).to eq(['hello'])
    end

    it 'captures nothing' do
      parser = string('hello').optional.capture!
      result = parser.run('')

      expect(result.captures).to eq([])
    end

    context 'when product' do
      it 'matches optional part' do
        parser = c("start") >> c("1").optional >> c("end")
        result = parser.run("start1end")

        expect(result.success?).to be_truthy
        expect(result.value.flatten).to eq(["start", "1", "end"])
      end

      it 'skips optional part' do
        parser = c("start") >> c("1").optional >> c("end")
        result = parser.run("startend")

        expect(result.success?).to be_truthy
        expect(result.value.flatten).to eq(["start", "end"])
      end

      it 'doesnt match the input - it will not make it optional' do
        parser = c("start") >> c("1").optional >> c("end")
        result = parser.run("start2end")

        expect(result.success?).to be_falsey
      end
    end
  end
end