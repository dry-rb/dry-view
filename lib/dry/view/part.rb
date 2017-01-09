require 'dry-equalizer'
require 'inflecto'

module Dry
  module View
    class Part
      def self.build(renderer:, value:, name: nil)
        case value
        when nil
          NullPart.new(renderer: renderer, value: value, name: name)
        when Array
          el_name = Inflecto.singularize(name).to_sym
          parts = value.map { |el| build(renderer: renderer, name: el_name, value: el) }

          new(renderer: renderer, value: parts, name: name)
        else
          new(renderer: renderer, value: value, name: name)
        end
      end

      include Dry::Equalizer(:_name, :_value, :_renderer)

      attr_reader :_renderer
      attr_reader :_value
      attr_reader :_name

      def initialize(renderer:, value:, name: nil)
        @_renderer = renderer
        @_value = value
        @_name = name
      end

      def render(path, scope = {}, &block)
        _renderer.render(path, with(scope), &block)
      end

      def to_s
        _value.to_s
      end

      def with(scope)
        if scope.any?
          Part.build(
            renderer: _renderer,
            value: merge(scope),
            name: _name,
          )
        else
          self
        end
      end

      def respond_to_missing?(name, include_private = false)
        template?(name) || _value.respond_to?(name) || super
      end

      private

      def method_missing(name, *args, &block)
        template_path = template?(name)

        if template_path
          render(template_path, scope(name, *args), &block)
        elsif _value.respond_to?(name)
          _value.public_send(name, *args, &block)
        elsif _value.kind_of?(Hash)
          _value[name]
        elsif _name && name == _name.to_sym
          _value
        else
          super
        end
      end

      def template?(name)
        _renderer.lookup("_#{name}")
      end

      def merge(scope)
        # byebug
        # TODO: work out what to do here with a `nil` name
        {_name => _value}.merge(scope)
      end

      def scope(name, *args)
        if args.none?
          {}
        elsif args.length == 1 && args.first.respond_to?(:to_hash)
          args.first.to_hash
        else
          {name => args.length == 1 ? args.first : args}
        end
      end
    end
  end
end

require 'dry/view/null_part'
