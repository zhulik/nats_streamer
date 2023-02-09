# frozen_string_literal: true

require "erb"
require "yaml"

require "zeitwerk"

require "async"
require "async/notification"
require "nats/client"
require "memery"
require "faraday"

require "dry-initializer"
require "dry/struct"
require "dry/types"

loader = Zeitwerk::Loader.for_gem
loader.setup

require_relative "nats_streamer/version"

class NatsStreamer::Error < StandardError
  # Your code goes here...
end

loader.eager_load
