RSpec.describe Dry::View::DecoratesResolver do
  before do
    module Test
      class TagPart < Dry::View::Part
        def to_s
          "Custom tag wrapping #{_value}"
        end
      end
      class NestedPart < Dry::View::Part
        decorate :tags, as: TagPart
        def to_s
          "Custom nested wrapping #{_value}"
        end
      end

      class CustomPart < Dry::View::Part
        def to_s
          "Custom part wrapping #{_value}"
        end
      end
    end
  end
  subject(:decorates_resolver) { described_class.new }
  let(:renderer) { double('renderer') }
  let(:context) { double('context') }

  describe "#result" do
    it "is empty by defalut" do
      expect(decorates_resolver.result).to be_empty
    end
  end

  describe '#call' do
    let(:result) { decorates_resolver.call(part_class, value, renderer, context) }

    context 'Part without decorates' do
      let(:part_class) do
        Class.new(Dry::View::Part) do
          def to_s
            'Nothing special'
          end
        end
      end
      let(:value) { {} }

      it 'return empty result' do
        expect(result).to eq({})
      end
    end

    context 'Part with decorates' do
      let(:part_class) do
        Class.new(Dry::View::Part) do
          decorate :prices, as: Test::CustomPart

          def to_s
            'Nothing special'
          end
        end
      end

      context 'when value respond to key' do
        let(:value) { OpenStruct.new(prices: 'hello') }

        it 'return result with key' do
          expect(result.keys).to eq([:prices])
        end

        it 'return result with value wrap in Part class' do
          expect(result[:prices].class).to eq Test::CustomPart
        end
      end

      context 'when value do not respond to key' do
        let(:value) { OpenStruct.new(products: 'hello') }

        it 'return empty result' do
          expect(result).to eq({})
        end
      end
    end

    context 'Part with nested decorate' do
      let(:part_class) do
        Class.new(Dry::View::Part) do
          decorate :prices, as: Test::NestedPart

          def to_s
            'Nothing special'
          end
        end
      end

      context 'when value respond to key' do
        let(:value) { OpenStruct.new(prices: 'hello', tags: [1,2]) }

        it 'return result with keys' do
          expect(result.keys).to eq([:tags, :prices])
        end

        it 'return result with values wrap in Part class' do
          expect(result[:prices].class).to eq Test::NestedPart
          expect(result[:tags].first.class).to eq Test::TagPart
        end
      end

      context 'when value do not respond to key' do
        let(:value) { OpenStruct.new(products: 'hello', tags: [1,2]) }

        it 'return result with key' do
          expect(result.keys).to eq([:tags])
        end
      end
    end
  end
end
