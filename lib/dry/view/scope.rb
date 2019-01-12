require 'dry/equalizer'
require 'dry/core/constants'

module Dry
  module View
    class Scope
      include Dry::Equalizer(:_name, :_locals, :_rendering)

      attr_reader :_name
      attr_reader :_locals
      attr_reader :_rendering

      def initialize(name: nil, locals: Dry::Core::Constants::EMPTY_HASH, rendering:)
        @_name = name
        @_locals = locals
        @_rendering = rendering
      end

      def render(partial_name = nil, **locals, &block)
        partial_name ||= _name
        raise ArgumentError, "+partial_name+ must be provided for unnamed scopes" unless partial_name
        partial_name = _inflector.underscore(_inflector.demodulize(partial_name.to_s)) if partial_name.is_a?(Class)

        _rendering.partial(partial_name, _render_scope(locals), &block)
      end

      def scope(name = nil, **locals)
        _rendering.scope(name, locals)
      end

      def context
        _rendering.context
      end

      private

      def method_missing(name, *args, &block)
        if _locals.key?(name)
          _locals[name]
        elsif context.respond_to?(name)
          context.public_send(name, *args, &block)
        else
          super
        end
      end

      def _render_scope(**locals)
        if locals.none?
          self
        else
          self.class.new(
            # FIXME: what about `name`?
            locals: locals,
            rendering: _rendering,
          )
        end
      end

      def _inflector
        _rendering.inflector
      end
    end
  end
end
