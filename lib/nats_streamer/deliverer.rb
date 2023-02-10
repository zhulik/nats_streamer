# frozen_string_literal: true

class NatsStreamer::Deliverer
  extend Dry::Initializer

  include NatsStreamer::Logger
  include Memery

  option :subscriber

  def deliver(**)
    info_measure(-> { connection.post(".", **) }) { "Event delivered to #{subscriber.name}: #{_1.round(2)}s" }
  end

  memoize def connection = NatsStreamer::Connection.build(subscriber.url)
end
