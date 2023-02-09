# frozen_string_literal: true

class NatsStreamer::Deliverer
  extend Dry::Initializer

  include NatsStreamer::Logger
  include Memery

  # TODO: how to propely unsubscribe?
  option :subscriber

  def deliver(**) = connection.post(".", **)

  memoize def connection
    Faraday.new(subscriber.url) do |f|
      f.request :json
      f.response :raise_error
    end
  end
end
