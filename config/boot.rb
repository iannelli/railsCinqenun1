ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap' # Speed up boot time by caching expensive operations.
Bootsnap.setup(
  cache_dir: 'tmp/readonly'
)