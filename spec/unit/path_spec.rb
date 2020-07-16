# frozen-string-literal: true

require "dry/view/path"

RSpec.describe Dry::View::Path do
  subject(:path) { Dry::View::Path.new(SPEC_ROOT.join("fixtures/templates")) }

  it "returns path as String when cast as String" do
    expect(path.to_s).to eq SPEC_ROOT.join("fixtures/templates").to_s
  end
end
