# frozen_string_literal: true

class NatsStreamer::ParamsRenderer
  include NatsStreamer::Helpers

  option :subject, type: T::String
  option :params, type: T::Hash.map(T::Coercible::Symbol, T::String)

  def render(event)
    params.transform_values do |v|
      binding.local_variable_set(:event, event)
      ERB.new(v).result(binding)
    end.merge(event:, subject:)
  end
end
