# frozen_string_literal: true

module NatsStreamer::Logger
  [:debug, :info, :warn, :error, :fatal].each do |name|
    define_method(name) do |msg = nil, &block|
      Console.logger.public_send(name, self, msg, &block)
    end

    define_method("#{name}_measure") do |lambda, msg = nil, &block|
      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC).then do |start|
        lambda.call
        Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
      end

      return public_send(name, msg) { block.call(elapsed) } unless block.nil?

      public_send(name, msg)
    end
  end
end
