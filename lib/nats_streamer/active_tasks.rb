# frozen_string_literal: true

class NatsStreamer::ActiveTasks
  include NatsStreamer::Helpers

  def async
    tasks << Async do |task|
      task.yield
      yield(task)
      tasks.delete(task)
    end
  end

  def wait = tasks.each(&:wait)

  private

  memoize def tasks = []
end
