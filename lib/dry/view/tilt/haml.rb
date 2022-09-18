# frozen_string_literal: true

module Dry
  class View
    module Tilt
      module Haml
        def self.requirements
          ["hamlit", <<~ERROR]
            dry-view requires hamlit (3.0 or greater) for full compatibility when rendering .haml templates (e.g. implicitly capturing block content when yielding)

            To ignore this and use another engine for .haml templates, dereigster this adapter before calling your views:

            Dry::View::Tilt.deregister_adatper(:haml)
          ERROR
        end

        def self.activate
          # Requiring hamlit will register the engine with Tilt
          self
        end
      end

      register_adapter :haml, Haml
    end
  end
end
