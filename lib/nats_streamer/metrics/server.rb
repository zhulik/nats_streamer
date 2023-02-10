# frozen_string_literal: true

class NatsStreamer::Metrics::Server
  include NatsStreamer::Helpers

  PATHS = ["/metrics", "/metrics/"].freeze

  NOT_FOUND = Protocol::HTTP::Response[404, {}, ["Not found"]].freeze

  option :port, type: T::Integer
  option :metrics_store, type: T.Instance(NatsStreamer::Metrics::Store)

  def run = @task = Async { Async::HTTP::Server.new(method(:app), endpoint).run }

  def stop = @task.stop
  def wait = @task.wait

  private

  memoize def endpoint = Async::HTTP::Endpoint.parse("http://127.0.0.1:#{port}")

  def app(request)
    return NOT_FOUND unless PATHS.include?(request.path)

    Protocol::HTTP::Response[200, {}, serialize_metrics]
  end

  def serialize_metrics
    metrics_store.metrics.map do |value|
      "#{metric_name(value)}{#{metric_tags(value)}} #{value[:value]}"
    end.join("\n")
  end

  def metric_name(value, unit = "total")
    "nats_streamer_#{value[:name]}_#{unit}"
  end

  def metric_tags(value) = value[:tags].map { |tag, tag_value| "#{tag}=#{tag_value.to_s.inspect}" }.join(",")
end
