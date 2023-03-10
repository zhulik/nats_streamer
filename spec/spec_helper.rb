# frozen_string_literal: true

ENV["CONSOLE_LEVEL"] ||= "fatal"

require "webmock/rspec"
require "async/rspec"

require "simplecov"

SimpleCov.start

require "nats_streamer"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include_context(Async::RSpec::Reactor, async: true)
  config.include_context(Async::RSpec::Leaks, async: true)
end
