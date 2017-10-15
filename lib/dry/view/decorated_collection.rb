module Dry
  module View
    class DecoratedCollection
      attr_reader :name, :options, :proc

      def initialize(name, options, proc)
        @name = name
        @options = options
        @proc = proc
      end

      def call(value, renderer, context)
        singular_name = singular_name(name)
        value.to_ary.map do |val|
          part_class.new(name: singular_name, value: val, renderer: renderer, context: context)
        end
      end

      private

      def singular_name(name)
        Dry::Core::Inflector.singularize(name).to_sym
      end

      def part_class
        options.fetch(:as)
      end
    end
  end
end
