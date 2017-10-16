module Dry
  module View
    class DecoratesResolver
      def self.call(part_class, value, renderer, context)
        new.call(part_class, value, renderer, context)
      end

      attr_reader :result
      def initialize
        @result = {}
      end

      def call(part_class, value, renderer, context)
        part_class.decorates.each do |key, decorate|
          if decorate.part_class.decorates.any?
            call(decorate.part_class, value, renderer, context)
          end
          result[key] = decorate.call(value, renderer, context) if valid_key?(value, key)
        end
        result
      end

      private

      def valid_key?(value, key)
        value.respond_to?(key) && value.public_send(key)
      end
    end
  end
end
