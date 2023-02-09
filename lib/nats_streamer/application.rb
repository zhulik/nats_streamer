# frozen_string_literal: true

class NatsStreamer::Application
  extend Dry::Initializer

  include NatsStreamer::Logger
  include Memery

  option :config

  def run
    config.streams.each do |name, subjects|
      NatsStreamer::Stream.new(jsm:, name:, subjects:).run
    end

    Async::Notification.new.wait # wait forever
  end

  private

  memoize def jsm
    NATS.connect(config.server_url).tap do
      info { "Connected to #{config.server_url}" }
    end.jsm
  end
end
