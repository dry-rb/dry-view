RSpec.describe Dry::View::Controller do
  subject(:controller) {
    Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = 'app'
        config.template = 'user'
      end
    end.new
  }

  let(:context) {
    Class.new(Dry::View::Context) do
      def title
        'Test'
      end
    end.new
  }

  let(:options) do
    { context: context, locals: { user: { name: 'Jane' }, header: { title: 'User' } } }
  end

  describe '#call' do
    it 'renders template within the layout' do
      expect(controller.(options)).to eql(
        '<!DOCTYPE html><html><head><title>Test</title></head><body><h1>User</h1><p>Jane</p></body></html>'
      )
    end

    it 'provides a meaningful error if the template name is missing' do
      controller = Class.new(Dry::View::Controller) do
        configure do |config|
          config.paths = SPEC_ROOT.join('fixtures/templates')
        end
      end.new

      expect { controller.(options) }.to raise_error Dry::View::Controller::UndefinedTemplateError
    end
  end
end
