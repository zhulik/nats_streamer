# frozen_string_literal: true

class NatsStreamer::Deliverer
  include NatsStreamer::Helpers

  option :subscriber, type: T.Instance(NatsStreamer::Config::Subscriber)
  option :metrics_store, type: T.Instance(NatsStreamer::Metrics::Store)

  def deliver(**params)
    name = params.dig(:event, :name)
    info_measure(-> { "Event #{name.inspect} delivered to #{subscriber.name.inspect}: #{_1.round(2)}s" }) do
      connection.post(".", **params)
    end
    metrics_store.inc(:delivered, subscriber: subscriber.name)
  end

  private

  memoize def connection = NatsStreamer::Connection.build(subscriber.url)
end
