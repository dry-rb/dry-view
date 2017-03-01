require 'dry-equalizer'

module Dry
  module View
    class Scope
      include Dry::Equalizer(:_renderer, :_data)

      attr_reader :_renderer
      attr_reader :_data
      attr_reader :_context

      def initialize(renderer, data, context = nil)
        @_renderer = renderer
        @_data = data.to_hash
        @_context = context
      end

      def render(name, *args, &block)
        path = _renderer.lookup(_partial_name(name))
        raise "template +#{path}+ not found" unless path

        _renderer.render(path, _render_args(*args), &block)
      end

      def respond_to_missing?(name, include_private = false)
        _template?(name) || _data.key?(name) || _context.respond_to?(name)
      end

      private

      def method_missing(name, *args, &block)
        if _data.key?(name)
          _data[name]
        elsif _context.respond_to?(name)
          _context.public_send(name, *args, &block)
        else
          super
        end
      end

      def _partial_name(name)
        parts = name.split("/")
        parts[-1] = "_#{parts[-1]}"

        parts.join("/")
      end

      def _render_args(*args)
        if args.empty?
          self
        elsif args.length == 1 && args.first.respond_to?(:to_hash)
          self.class.new(_renderer, args.first, _context)
        else
          raise ArgumentError, "render argument must be a Hash"
        end
      end
    end
  end
end
