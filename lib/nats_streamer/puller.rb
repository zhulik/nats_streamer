# frozen_string_literal: true

class NatsStreamer::Puller
  include NatsStreamer::Helpers

  option :jsm, type: T.Instance(NATS::JetStream)
  option :subject, type: T::String
  option :durable, type: T::String
  option :deliver_group, default: -> { "nats_streamer" }

  def pull(&)
    retry_loop(NATS::IO::Timeout) { psub.fetch(1).each(&) }
  rescue ThreadError
    psub.unsubscribe
  end

  private

  memoize def psub = jsm.pull_subscribe(subject, durable, config: { deliver_group: })

  def retry_loop(exception)
    loop do
      yield
    rescue exception
      debug { "Retrying on #{exception}" }
    end
  end
end
