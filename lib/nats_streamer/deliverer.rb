# frozen_string_literal: true

class NatsStreamer::Deliverer
  extend Dry::Initializer

  include NatsStreamer::Logger
  include Memery

  # TODO: how to propely unsubscribe?
  option :subscriber

  def deliver(**)
    info_measure(-> { connection.post(".", **) }) { "Event delivered to #{subscriber.name}: #{_1.round(2)}s" }
  rescue StandardError => e
    warn { "Event failed to be delivered to #{subscriber.name}" }
    warn { e }
  end

  memoize def connection = NatsStreamer::Connection.build(subscriber.url)
end
