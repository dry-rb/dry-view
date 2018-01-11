require 'dry-equalizer'
require 'dry/view/scope'
require 'dry/view/decorates'
require 'dry/view/missing_renderer'

module Dry
  module View
    class Part
      CONVENIENCE_METHODS = %i[
        context
        render
        value
      ].freeze

      def self.decorate(name, **options, &block)
        decorates.add(name, options, block)
      end

      def self.decorates
        @decorates ||= Decorates.new
      end

      include Dry::Equalizer(:_name, :_value, :_context, :_renderer)

      attr_reader :_name

      attr_reader :_value

      attr_reader :_context

      attr_reader :_renderer

      attr_reader :_decorated_children

      def initialize(name:, value:, renderer: MissingRenderer.new, context: nil, decorated_children: {})
        @_name = name
        @_value = value
        @_context = context
        @_renderer = renderer
        @_decorated_children = decorated_children
      end

      def _render(partial_name, as: _name, **locals, &block)
        _renderer.partial(partial_name, _render_scope(as, locals), &block)
      end

      def to_s
        _value.to_s
      end

      private

      def method_missing(name, *args, &block)
        if _decorated_children.key?(name)
          _decorated_children[name]
        elsif _value.respond_to?(name)
          _value.public_send(name, *args, &block)
        elsif CONVENIENCE_METHODS.include?(name)
          __send__(:"_#{name}", *args, &block)
        else
          super
        end
      end

      def _render_scope(name, **locals)
        Scope.new(
          locals: locals.merge(name => self),
          context: _context,
          renderer: _renderer,
        )
      end
    end
  end
end
