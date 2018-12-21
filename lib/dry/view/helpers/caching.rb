# frozen_string_literal: true

module Dry
  module View
    module Helpers
      module Caching
        def self.included(base)
          class << base
            def fetch_from_cache_or_store(key)
              cached_values.fetch(key) do
                cached_values[key] = yield
              end
            end

            def reset_cache
              @cached_values = {}
            end

            private

            def cached_values
              @cached_values ||= {}
            end
          end
        end
      end
    end
  end
end
