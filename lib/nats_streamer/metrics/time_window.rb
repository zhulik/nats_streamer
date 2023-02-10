# frozen_string_literal: true

class NatsStreamer::Metrics::TimeWindow
  include NatsStreamer::Helpers

  option :duration, type: T::Integer # milliseconds

  def push(value)
    purge_old!
    history << [timestamp, value]
  end

  def stats
    purge_old!
    values = history.map { _1[1] }

    avg = values.count.positive? ? values.sum.to_f / values.count : nil

    min, max = values.minmax
    {
      min:,
      max:,
      avg:,
      count:
    }
  end

  def count = history.count

  private

  memoize def history = []

  def timestamp = (Time.now.to_f * 1000).to_i

  def purge_old!
    now = timestamp

    index = history.bsearch_index { _1.first > (now - duration) }
    history.clear if index.nil?
    history.shift(index) if index
  end
end
