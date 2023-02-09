# frozen_string_literal: true

class NatsStreamer::ParamsRenderer
  extend Dry::Initializer

  include NatsStreamer::Logger
  include Memery

  option :subject
  option :subscriber

  def render(event)
    subscriber.params.transform_values do |v|
      binding.local_variable_set(:event, event)
      ERB.new(v).result(binding)
    end.merge(event:, subject:)
  end
end
