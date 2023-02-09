# frozen_string_literal: true

class NatsStreamer::Application
  extend Dry::Initializer

  include NatsStreamer::Logger
  include Memery

  option :url
  option :config

  def run
    config.streams.each do |name, subjects|
      NatsStreamer::Stream.new(jsm:, name:, subjects:).run
    end

    Async::Notification.new.wait # wait forever
  end

  private

  memoize def client = NATS.connect(url)

  def jsm = client.jsm
end
