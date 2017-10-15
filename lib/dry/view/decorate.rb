module Dry
  module View
    class Decorate
      attr_reader :name, :options, :proc

      def initialize(name, options, proc)
        @name = name
        @options = options
        @proc = proc
      end

      def call(local_value, renderer, context)
        singular_name = singular_name(name)
        value = local_value.public_send(name)
        if value.respond_to?(:to_ary)
          value.map do |val|
            part_class.new(name: singular_name, value: val, renderer: renderer, context: context)
          end
        else
          part_class.new(name: singular_name, value: value, renderer: renderer, context: context)
        end
      end

      def part_class
        options.fetch(:as)
      end

      private

      def singular_name(name)
        Dry::Core::Inflector.singularize(name).to_sym
      end
    end
  end
end
