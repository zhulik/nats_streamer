# frozen_string_literal: true

class NatsStreamer::Metrics::Store
  include NatsStreamer::Helpers

  def run
    @task = Async do
      queue.each do |action, name, tags|
        send("perform_#{action}", name, tags)
      end
    end
  end

  def inc(name, **tags)
    queue << [:inc, name, tags.merge(subscriber: "another_one")]
    queue << [:inc, name, tags]
  rescue RuntimeError
    nil
  end

  def metrics = counters.values
  def stop = @task.stop
  def wait = @task.wait

  private

  memoize def queue = Async::Queue.new

  memoize def counters = {}

  def perform_inc(name, tags)
    key = [name, tags] # Any uniq combination of name and tags will create a new counter

    counters[key] ||= {
      name:,
      tags:,
      value: 0
    }
    counters[key][:value] += 1
  end
end
