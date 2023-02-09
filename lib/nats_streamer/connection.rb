# frozen_string_literal: true

class NatsStreamer::Connection
  def self.build(url)
    Faraday.new(url) do |f|
      f.request :json
      f.response :raise_error
    end
  end
end
