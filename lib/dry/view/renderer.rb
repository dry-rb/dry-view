require 'tilt'
require 'dry-equalizer'

module Dry
  module View
    class Renderer
      include Dry::Equalizer(:dir, :root, :engines)

      TemplateNotFoundError = Class.new(StandardError)

      attr_reader :dir, :root, :format, :engines, :tilts

      def self.tilts
        @__engines__ ||= {}
      end

      def initialize(dir, options = {})
        @dir = dir
        @root = options.fetch(:root, dir)
        @format = options[:format]
        @engines = Array(options[:engines])
        @tilts = self.class.tilts
      end

      def call(template, scope, &block)
        path = lookup(template)

        if path
          render(path, scope, &block)
        else
          raise TemplateNotFoundError, "Template #{template} could not be looked up within #{root}"
        end
      end

      def render(path, scope, &block)
        tilt(path).render(scope, &block)
      end

      def tilt(path)
        tilts.fetch(path) { tilts[path] = Tilt.new(path) }
      end

      def lookup(name)
        template?(name) || template?("shared/#{name}") || !root? && chdir('..').lookup(name)
      end

      def root?
        dir == root
      end

      def template?(name)
        paths(name).select do |template_path|
          File.exist?(template_path.to_s)
        end.first
      end

      def paths(name)
        engines.map do |engine|
          dir.join("#{name}.#{format}.#{engine}")
        end
      end

      def chdir(dirname)
        self.class.new(dir.join(dirname), engines: engines, format: format, root: root)
      end
    end
  end
end
