RSpec.describe 'decorator' do
  before do
    module Test
      class CustomPart < Dry::View::Part
        def to_s
          "Custom part wrapping #{_value}"
        end
      end

      class CustomArrayPart < Dry::View::Part
        def each(&block)
          (_value * 2).each(&block)
        end
      end

      class Product < Struct.new(:name, :tags, :prices)
      end

      class PricePart < Dry::View::Part
        def to_s
          "Custom price part wrapping #{_value}"
        end
      end

      class TagPart < Dry::View::Part
        decorate :prices, as: PricePart

        def to_s
          "Custom tag part wrapping #{_value}"
        end
      end

      class CustomProductsCollection < Dry::View::Part
        decorate :tags, as: TagPart
      end
    end
  end

  describe 'default decorator' do
    it 'supports wrapping array memebers in custom part classes provided to exposure :as option' do
      vc = Class.new(Dry::View::Controller) do
        configure do |config|
          config.paths = SPEC_ROOT.join('fixtures/templates')
          config.layout = nil
          config.template = 'decorated_parts'
        end

        expose :customs, as: Test::CustomPart
        expose :custom, as: Test::CustomPart
        expose :ordinary
      end.new

      expect(vc.(customs: ['many things'], custom: 'custom thing', ordinary: 'ordinary thing')).to eql(
        '<p>Custom part wrapping many things</p><p>Custom part wrapping custom thing</p><p>ordinary thing</p>'
      )
    end

    it 'supports wrapping an array and its members in custom part classes provided to exposure :as option as a hash' do
      vc = Class.new(Dry::View::Controller) do
        configure do |config|
          config.paths = SPEC_ROOT.join('fixtures/templates')
          config.layout = nil
          config.template = 'decorated_parts'
        end

        expose :customs, as: {Test::CustomArrayPart => Test::CustomPart}
        expose :custom, as: Test::CustomPart
        expose :ordinary
      end.new

      expect(vc.(customs: ['many things'], custom: 'custom thing', ordinary: 'ordinary thing')).to eql(
        '<p>Custom part wrapping many things</p><p>Custom part wrapping many things</p><p>Custom part wrapping custom thing</p><p>ordinary thing</p>'
      )
    end
  end

  describe 'custom decorator and part classes' do
    it 'supports wrapping in custom parts based on exposure names' do
      decorator = Class.new(Dry::View::Decorator) do
        def part_class(name, value, **options)
          name == :custom ? Test::CustomPart : super
        end
      end.new

      vc = Class.new(Dry::View::Controller) do
        configure do |config|
          config.decorator = decorator
          config.paths = SPEC_ROOT.join('fixtures/templates')
          config.layout = nil
          config.template = 'decorated_parts'
        end

        expose :customs, :custom, :ordinary
      end.new

      expect(vc.(customs: ['many things'], custom: 'custom thing', ordinary: 'ordinary thing')).to eql(
        '<p>Custom part wrapping many things</p><p>Custom part wrapping custom thing</p><p>ordinary thing</p>'
      )
    end
  end

  context 'Decorated collection' do
    it 'supports wrapping children as part object when children is an array' do
      vc = Class.new(Dry::View::Controller) do
        configure do |config|
          config.paths = SPEC_ROOT.join('fixtures/templates')
          config.layout = nil
          config.template = 'decorated_parts_product_children'
        end

        expose :product, as: Test::CustomProductsCollection
      end.new

      expect(vc.(product: Test::Product.new('test_1', ['hello', 'world']))).to eql(
        '<p>Custom tag part wrapping hello</p><p>Custom tag part wrapping world</p>'
      )
    end

    it 'supports wrapping children as part object when children is not an array' do
      vc = Class.new(Dry::View::Controller) do
        configure do |config|
          config.paths = SPEC_ROOT.join('fixtures/templates')
          config.layout = nil
          config.template = 'decorated_parts_product_children_non_array'
        end

        expose :product, as: Test::CustomProductsCollection
      end.new

      expect(vc.(product: Test::Product.new('test_1', 'hello'))).to eql(
        '<p>Custom tag part wrapping hello</p>'
      )
    end

    it 'supports nested wrapping children as part object' do
      vc = Class.new(Dry::View::Controller) do
        configure do |config|
          config.paths = SPEC_ROOT.join('fixtures/templates')
          config.layout = nil
          config.template = 'decorated_parts_product_children_with_prices'
        end

        expose :product, as: Test::CustomProductsCollection
      end.new

      expect(vc.(product: Test::Product.new('test_1', ['hello', 'world'], [123, 345]))).to eql(
        '<p>Custom tag part wrapping hello</p><p>Custom tag part wrapping world</p><p>Custom price part wrapping 123</p><p>Custom price part wrapping 345</p>'
      )
    end
  end
end
