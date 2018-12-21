require "dry/view/helpers/caching"

RSpec.describe Dry::View::Helpers::Caching do
  let(:cached) { spy(:cache) }

  let(:klass) do
    Class.new do
      include Dry::View::Helpers::Caching

      attr_reader :cached

      def initialize(cached)
        @cached = cached
      end

      def get(part)
        self.class.fetch_from_cache_or_store(part) do
          cached.stored
          "Stored #{part}"
        end
      end
    end.new(cached)
  end

  describe '#fetch_from_cache_or_store' do
    it 'stores the result after first call and use the cache value the second time is called' do
      klass.get('layout')
      klass.get('layout')
      expect(cached).to have_received(:stored).once
    end

    it 'returns the result from cache' do
      result = klass.get('layout')
      expect(result).to equal(klass.get('layout'))
    end
  end

  describe '#reset_cache' do
    it 'clears the cached values' do
      klass.get('layout')
      klass.class.reset_cache
      klass.get('layout')
      expect(cached).to have_received(:stored).twice
    end
  end
end
