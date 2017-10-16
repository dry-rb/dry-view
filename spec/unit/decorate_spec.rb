RSpec.describe Dry::View::Decorate do
  subject(:decorate) { described_class.new(:products, options, nil) }
  let(:options) { {as: Dry::View::Part} }
  let(:context) { double(:context) }
  let(:renderer) { double(:renderer) }

  describe '#part_class' do
    it 'return part class' do
      expect(decorate.part_class).to eq Dry::View::Part
    end
  end

  describe '#call' do
    let(:result) { decorate.call(OpenStruct.new(products: value), renderer, context) }

    context 'single value' do
      let(:value) { 'hello' }

      it 'return part object' do
        expect(result.class).to eq Dry::View::Part
        expect(result.value).to eq value
      end

      it 'return part object with singular name' do
        expect(result._name).to eq :product
      end
    end

    context 'array value' do
      let(:value) { ['hello', 'world'] }

      it 'return array with part objects' do
        expect(result.class).to eq Array
        expect(result.size).to eq 2
        expect(result.last.class).to eq Dry::View::Part
        expect(result.last.value).to eq 'world'
      end

      it 'return part object with singular name' do
        expect(result.first._name).to eq :product
      end
    end
  end
end
