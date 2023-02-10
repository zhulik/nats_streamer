# frozen_string_literal: true

RSpec.describe NatsStreamer::Application, async: true do
  let(:application) { described_class.new(config:) }
  let(:config) { NatsStreamer::Config.new(server_url: "nats://localhost:4222", streams:) }

  let(:streams) do
    {
      nats_streamer: {
        test_events: {
          event_name: [
            NatsStreamer::Config::Subscriber.new(name: "test_subscriber",
                                                 url: "https://example.com")
          ]
        }
      }
    }
  end

  let(:client) { NATS.connect("nats://127.0.0.1:4222") }
  let(:jsm) { client.jetstream }

  after do
    client.close
  end

  describe "#run" do
    let!(:stub) do
      stub_request(:post, "https://example.com/")
        .with(
          body: { "event" => { "name" => "event_name", "payload" => "some_payload" }, "subject" => "test_events.event_name" }
        )
        .to_return(status: 200, body: "", headers: {})
    end

    it "delivers received messages" do # rubocop:disable RSpec/ExampleLength
      app = Async { application.run }

      jsm.publish("test_events.event_name", { name: "event_name", payload: "some_payload" }.to_json)

      sleep(0.1)

      app.stop
      app.wait
      expect(stub).to have_been_requested
    end
  end
end
