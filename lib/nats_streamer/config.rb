# frozen_string_literal: true

class NatsStreamer::Config < Dry::Struct
  T = Dry.Types

  class Subscriber < Dry::Struct
    attribute :name, T::String # Must be uniq
    attribute :url, T::String
    attribute :params, T::Hash.map(T::Coercible::String, T::String).default({}.freeze)
  end

  Events = T::Hash.map(T::Coercible::String, T::Array.of(Subscriber))
  Subjects = T::Hash.map(T::Coercible::String, Events)

  attribute :server_url, T::Coercible::String
  attribute :streams, T::Hash.map(T::Coercible::String, Subjects)
end
