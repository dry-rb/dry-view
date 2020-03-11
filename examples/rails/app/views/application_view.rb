# frozen_string_literal: true

class ApplicationView < Dry::View
  config.paths = Rails.root.join("app/templates")
  config.default_context = ApplicationViewContext.new
end
