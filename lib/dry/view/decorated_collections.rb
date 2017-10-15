require "dry/view/decorated_collection"

module Dry
  module View
    class DecoratedCollections
      attr_reader :collection

      def initialize(collection = {})
        @collection = collection
      end

      def key?(name)
        collection.key?(name)
      end

      def [](name)
        collection[name]
      end

      def add(name, options, block)
        collection[name] = DecoratedCollection.new(name, options, block)
      end
    end
  end
end
