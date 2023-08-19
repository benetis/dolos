# frozen_string_literal: true

RSpec.describe Dolos do
  include Dolos

  describe 'product' do

    context 'when success' do
      it 'combines two parsers' do
        parser = string('hello') & string('world')
        result = parser.run('helloworld')

        expect(result.success?).to be_truthy
      end

      it 'combines three parsers' do
        parser = string('hello') & string('world') & string('!')
        result = parser.run('helloworld!')

        expect(result.success?).to be_truthy
      end

      it 'combines four parsers' do
        parser = string('hello') & string('world') & string('!') & string('!')
        result = parser.run('helloworld!!')

        expect(result.success?).to be_truthy
      end

      it 'combines five parsers' do
        parser = string('hello') & string(' ') & string('world') & string(',') & string(' and universe')
        result = parser.run('hello world, and universe')

        expect(result.success?).to be_truthy
      end
    end

    context 'when failure' do
      it 'tries to combine two parsers and returns failure' do
        parser = string('hello') & string('world')
        result = parser.run('helloX')

        expect(result.failure?).to be_truthy
      end

    end

    context 'when returning a value' do
      it 'returns parse value' do
        parser = string('hello') & string('X')
        result = parser.run('helloX')

        expect(result.value).to eq(['hello', 'X'])
      end
    end

    context 'when working with values' do
      it 'returns parse value and groups them' do
        parser = string('hello') & (string('X') & string('!'))
        result = parser.run('helloX!')

        expect(result.value).to eq(['hello', ['X', '!']])
      end

    end

  end

  describe 'product_l' do
    it 'combines two parsers and return left value' do
      parser = string('hello') << string('world')
      result = parser.run('helloworld')

      expect(result.success?).to be_truthy
      expect(result.value).to eq('hello')
    end

    it 'combines three parsers and return left value' do
      parser = string('hello') << string('world') << string('!')
      result = parser.run('helloworld!')

      expect(result.success?).to be_truthy
      expect(result.value).to eq('hello')
    end

    it 'works with captures' do
      parser = (string('hello') << string('world')).capture! << string('!')
      result = parser.run('helloworld!')

      expect(result.success?).to be_truthy
      expect(result.captures).to eq(['hello'])
      expect(result.value).to eq('hello')
    end

    it 'will not discard captures' do
      parser = string('hello') << string('world') << string('!').capture!
      result = parser.run('helloworld!')

      expect(result.success?).to be_truthy
      expect(result.captures).to eq(['!'])
      expect(result.value).to eq('hello')
    end

    it 'will not duplicate captures' do
      parser = string('hello').capture! << string('world').capture! << string('!')
      result = parser.run('helloworld!')

      expect(result.success?).to be_truthy
      expect(result.captures).to eq(['hello', 'world'])
      expect(result.value).to eq('hello')
    end
  end

  describe 'product_r' do
    it 'combines two parsers and return right value' do
      parser = string('hello') >> string('world')
      result = parser.run('helloworld')

      expect(result.success?).to be_truthy
      expect(result.value).to eq('world')
    end

    it 'combines three parsers and return right value' do
      parser = string('hello') >> string('world') >> string('!')
      result = parser.run('helloworld!')

      expect(result.success?).to be_truthy
      expect(result.value).to eq('!')
    end

    it 'works with captures' do
      parser = (string('hello') >> string('world')).capture! >> string('!')
      result = parser.run('helloworld!')

      expect(result.success?).to be_truthy
      expect(result.captures).to eq(['world'])
      expect(result.value).to eq('!')
    end

    it 'will not discard captures' do
      parser = string('hello').capture! >> string('world') >> string('!')
      result = parser.run('helloworld!')

      expect(result.success?).to be_truthy
      expect(result.captures).to eq(['hello'])
      expect(result.value).to eq('!')
    end

    it 'will not duplicate captures' do
      parser = string('hello').capture! >> string('world').capture! >> string('!')
      result = parser.run('helloworld!')

      expect(result.success?).to be_truthy
      expect(result.captures).to eq(['hello', 'world'])
      expect(result.value).to eq('!')
    end
  end

end