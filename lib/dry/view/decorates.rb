require "dry/view/decorate"

module Dry
  module View
    class Decorates
      attr_reader :decorates

      def initialize(decorates = {})
        @decorates = decorates
      end

      def [](name)
        decorates[name]
      end

      def any?
        decorates.any?
      end

      def each
        decorates.each do |key, decorate|
          yield(key, decorate)
        end
      end

      def add(name, options, block)
        decorates[name] = Decorate.new(name, options, block)
      end
    end
  end
end
