if RUBY_ENGINE == 'ruby'
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
  end
end

begin
  require 'pry-byebug'
rescue LoadError; end

SPEC_ROOT = Pathname(__FILE__).dirname
FIXTURES_PATH = SPEC_ROOT.join("fixtures")

require 'erb'
require 'slim'

# Prefer plain ERB processor rather than erubis (which has problems on JRuby)
require 'tilt'
Tilt.register 'erb', Tilt::ERBTemplate

require 'dry-view'

module Test
  def self.remove_constants
    constants.each(&method(:remove_const))
  end
end

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.order = :random
  Kernel.srand config.seed

  config.after do
    Test.remove_constants
    Dry::View::Path.reset_cache
    Dry::View::PartBuilder.reset_cache
  end
end

RSpec::Matchers.define :part_including do |data|
  match { |actual|
    data.all? { |(key, val)|
      actual._data[key] == val
    }
  }
end
