require "pathname"

module Dry
  module View
    class Path
      include Dry::Equalizer(:dir, :root)

      attr_reader :dir, :root

      def initialize(dir, options = {})
        @dir = Pathname(dir)
        @root = Pathname(options.fetch(:root, dir))
      end

      def lookup(name, format)
        # Search for a template using a wildcard for the engine extension
        glob = dir.join("#{name}.#{format}.*")
        Dir[glob].first
      end

      def chdir(dirname)
        self.class.new(dir.join(dirname), root: root)
      end

      def to_s
        dir
      end
    end
  end
end
