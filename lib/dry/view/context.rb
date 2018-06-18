module Dry
  module View
    class Context
      attr_reader :_renderer
      attr_reader :_decorator
      attr_reader :_args

      def initialize(_renderer: nil, _decorator: nil, **args)
        @_renderer = _renderer
        @_decorator = _decorator
        @_args = args
      end

      def _renderer
        @_renderer or raise "not ready to render"
      end

      def _decorator
        @_decorator or raise "not ready to render"
      end

      def for_rendering(renderer:, decorator:)
        self.class.new(
          _renderer: renderer,
          _decorator: decorator,
          **_args,
        )
      end
    end
  end
end


