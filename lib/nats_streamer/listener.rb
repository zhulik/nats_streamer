# frozen_string_literal: true

class NatsStreamer::Listener
  extend Dry::Initializer

  include NatsStreamer::Logger
  include Memery

  # TODO: how to propely unsubscribe?
  option :jsm
  option :subject
  option :subscriber

  def run
    pull do |msg|
      Async { handle_message(msg) }
    end
  end

  private

  memoize def params_renderer = NatsStreamer::ParamsRenderer.new(subject:, subscriber:)
  memoize def deliverer(subscriber) = NatsStreamer::Deliverer.new(subscriber:)

  def pull(&)
    psub = @jsm.pull_subscribe(subject, "nats-streamer-subscriber-#{subscriber.name}")

    loop do
      psub.fetch(1).each(&)
    rescue NATS::IO::Timeout
      debug { "Pulling timeout, retrying..." }
    end
  end

  def handle_message(msg)
    event = JSON.parse(msg.data, symbolize_names: true)
    debug { "subject=#{subject}, event=#{event}" }

    deliverer(subscriber).deliver(**params_renderer.render(event))

    msg.ack
  end
end
