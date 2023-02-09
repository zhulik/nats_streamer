# frozen_string_literal: true

class NatsStreamer::Config < Dry::Struct
  Types = Dry.Types

  class Subscriber < Dry::Struct
    attribute :name, Types::String # Must be uniq
    attribute :url, Types::String
    attribute :params, Types::Hash.map(Types::Coercible::String, Types::String).default({}.freeze)
  end

  attribute :streams, Types::Hash.map(
    Types::Coercible::String,
    Types::Hash.map(
      Types::Coercible::String,
      Types::Hash.map(
        Types::Coercible::String,
        Types::Array.of(Subscriber)
      )
    )
  )
end
