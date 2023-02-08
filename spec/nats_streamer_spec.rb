# frozen_string_literal: true

RSpec.describe NatsStreamer do
  it "has a version number" do
    expect(NatsStreamer::VERSION).not_to be_nil
  end
end
