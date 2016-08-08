require 'dry/view/path'
require 'dry/view/renderer'

RSpec.describe Dry::View::Renderer do
  subject(:renderer) do
    Dry::View::Renderer.new([Dry::View::Path.new(SPEC_ROOT.join('fixtures/templates'))], format: 'html', engines: :slim)
  end

  let(:scope) { double(:scope) }

  describe '#call' do
    it 'renders template' do
      expect(renderer.('hello', scope)).to eql('<h1>Hello</h1>')
    end

    it 'looks up shared template in current dir' do
      expect(renderer.('_shared_hello', scope)).to eql('<h1>Hello</h1>')
    end

    it 'looks up shared template in upper dir' do
      expect(renderer.chdir('greetings').('_shared_hello', scope)).to eql('<h1>Hello</h1>')
    end

    it 'raises error when template was not found' do
      expect {
        renderer.('not_found', scope)
      }.to raise_error(Dry::View::Renderer::TemplateNotFoundError, /not_found/)
    end
  end
end
