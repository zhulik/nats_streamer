# frozen_string_literal: true

class NatsStreamer::Listener
  include NatsStreamer::Helpers

  option :jsm, type: T.Instance(NATS::JetStream)
  option :subject, type: T::Coercible::String
  option :subscriber, type: T.Instance(NatsStreamer::Config::Subscriber)
  option :metrics_store, type: T.Instance(NatsStreamer::Metrics::Store)

  def run
    info { "Subscribing to #{subject}" }

    puller.pull { handle_message(_1) }
    wait
  end

  private

  memoize def durable = "nats-streamer-subscriber-#{subscriber.name}"
  memoize def params_renderer = NatsStreamer::ParamsRenderer.new(subject:, params: subscriber.params)
  memoize def active_tasks = NatsStreamer::ActiveTasks.new
  memoize def puller = NatsStreamer::Puller.new(jsm:, subject:, durable:)
  memoize def deliverer = NatsStreamer::Deliverer.new(subscriber:, metrics_store:)

  def wait = active_tasks.wait

  def handle_message(msg)
    active_tasks.async do
      event = JSON.parse(msg.data, symbolize_names: true)
      debug { "subject=#{subject}, event=#{event}" }

      deliverer.deliver(**params_renderer.render(event))

      msg.ack
    end
  end
end
