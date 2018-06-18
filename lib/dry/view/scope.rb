require 'dry-equalizer'

module Dry
  module View
    class Scope
      include Dry::Equalizer(:_locals, :_context)

      attr_reader :_locals
      attr_reader :_context

      def initialize(context:, locals: {})
        @_locals = locals
        @_context = context
      end

      def render(partial_name, **locals, &block)
        _context._renderer.partial(partial_name, __render_scope(locals), &block)
      end

      private

      def method_missing(name, *args, &block)
        if _locals.key?(name)
          _locals[name]
        elsif _context.respond_to?(name)
          _context.public_send(name, *args, &block)
        else
          super
        end
      end

      def __render_scope(**locals)
        if locals.any?
          self.class.new(context: _context, locals: locals)
        else
          self
        end
      end
    end
  end
end
