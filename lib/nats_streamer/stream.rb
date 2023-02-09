# frozen_string_literal: true

class NatsStreamer::Stream
  extend Dry::Initializer

  include NatsStreamer::Logger
  include Memery

  option :jsm
  option :name
  option :subjects

  def run
    create_stream!

    subjects.each do |subject, events|
      events.each do |event_name, subscribers|
        subscribers.each do |subscriber|
          subject = [subject, event_name].join(".")
          NatsStreamer::Listener.new(jsm:, subject:, subscriber:).run
        end
      end
    end
  end

  private

  # ["{subject_name}.{event_name}"]
  memoize def subject_names
    subjects.flat_map do |subject, events|
      [subject].product(events.keys).map { _1.join(".") }
    end
  end

  def create_stream!
    info { "Creating stream '#{name}' with subjects #{subject_names}" }

    jsm.add_stream(name:, subjects: subject_names)
  rescue NATS::JetStream::Error::BadRequest
    warn { "Configuration changed, attempting deleting and recreating stream #{name}" }

    jsm.delete_stream(name)
    retry
  end
end
