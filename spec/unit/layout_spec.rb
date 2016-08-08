RSpec.describe Dry::View::Layout do
  subject(:layout) { layout_class.new }

  let(:layout_class) do
    klass = Class.new(Dry::View::Layout)

    klass.configure do |config|
      config.paths = SPEC_ROOT.join('fixtures/templates')
      config.name = 'app'
      config.template = 'user'
      config.formats = {html: [:slim, :erb]}
    end

    klass
  end

  let(:page) do
    double(:page, title: 'Test')
  end

  let(:options) do
    { scope: page, locals: { user: { name: 'Jane' }, header: { title: 'User' } } }
  end

  let(:renderer) do
    layout.class.renderers[:html]
  end

  describe '#call' do
    it 'renders template within the layout' do
      expect(layout.(options)).to eql(
        '<!DOCTYPE html><html><head><title>Test</title></head><body><h1>User</h1><p>Jane</p></body></html>'
      )
    end
  end

  describe '#parts' do
    it 'returns view parts' do
      part = layout.parts({ user: { id: 1, name: 'Jane' } }, renderer)

      expect(part[:id]).to be(1)
      expect(part[:name]).to eql('Jane')
    end

    it 'builds null parts for nil values' do
      part = layout.parts({ user: nil }, renderer)

      expect(part[:id]).to be_nil
    end

    it 'returns empty part when no locals are passed' do
      expect(layout.parts({}, renderer)).to be_instance_of(Dry::View::Part)
    end
  end
end
