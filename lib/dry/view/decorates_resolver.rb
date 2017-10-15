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
          if decorate.part_class.decorates.any? && value.public_send(key)
            call(decorate.part_class, value, renderer, context)
          end
          result[key] = decorate.call(value, renderer, context) if value.public_send(key)
        end
        result
      end
    end
  end
end
