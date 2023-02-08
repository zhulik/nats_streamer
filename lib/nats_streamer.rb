# frozen_string_literal: true

require "zeitwerk"

require "async"
require "nats/client"

loader = Zeitwerk::Loader.for_gem
loader.setup

require_relative "nats_streamer/version"

class NatsStreamer::Error < StandardError
  # Your code goes here...
end

loader.eager_load
