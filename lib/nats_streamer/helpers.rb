# frozen_string_literal: true

module NatsStreamer::Helpers
  T = Dry.Types

  def self.included(base)
    base.extend(Dry::Initializer)
    base.include(NatsStreamer::Logger)
    base.include(Memery)
  end
end
