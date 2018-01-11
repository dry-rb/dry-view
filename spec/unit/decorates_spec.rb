RSpec.describe Dry::View::Decorates do
  subject(:decorates) { described_class.new }

  describe "#decorates" do
    it "is empty by defalut" do
      expect(decorates.decorates).to be_empty
    end
  end

  describe "#add" do
    it "creates and adds a decorate" do
      options = {foo: :bar}
      decorates.add :hello, options

      expect(decorates[:hello].name).to eq :hello
      expect(decorates[:hello].options).to eq options
    end
  end

  describe "#each" do
    before do
      decorates.add(:greeting, {foo: :bar})
    end


    it "yield each key and decorate object" do
      decorate = decorates[:greeting]
      expect { |b| decorates.each(&b) }.to yield_with_args([:greeting, decorate])
    end
  end
end
