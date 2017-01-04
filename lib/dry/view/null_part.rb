require 'dry-equalizer'

module Dry
  module View
    class NullPart < Part
      def respond_to_missing?(*)
        true
      end

      private

      def method_missing(meth, *args, &block)
        template_path = template?("#{meth}_missing")

        if template_path
          render(template_path, scope(meth, *args), &block)
        else
          nil
        end
      end
    end
  end
end
