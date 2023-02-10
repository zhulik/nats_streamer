# frozen_string_literal: true

class NatsStreamer::Application
  include NatsStreamer::Helpers

  option :config, type: T.Instance(NatsStreamer::Config)

  def run
    metrics_store.run
    metrics_server.run
    wait
  ensure
    stop
    wait

    client.close
  end

  def stop
    metrics_server.stop
    streams.each(&:stop)
    metrics_store.stop
  end

  def wait
    metrics_server.wait
    streams.each(&:wait)
    metrics_store.wait
  end

  private

  memoize def jsm = client.jsm

  # TODO: move port to config
  memoize def metrics_server = NatsStreamer::Metrics::Server.new(port: 9294, metrics_store:)
  memoize def metrics_store = NatsStreamer::Metrics::Store.new

  memoize def streams
    config.streams.map do |name, subjects|
      NatsStreamer::Stream.new(jsm:, name:, subjects:, metrics_store:).tap(&:run)
    end
  end

  memoize def client
    NATS.connect(config.server_url).tap do
      info { "Connected to #{config.server_url}" }
    end
  end
end
