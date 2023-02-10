# frozen_string_literal: true

RSpec.describe NatsStreamer::Deliverer do
  let(:deliverer) { described_class.new(subscriber:) }
  let(:subscriber) { instance_double(NatsStreamer::Config::Subscriber, url: "https://example.com", name: "test") }

  describe "#deliver" do
    subject { deliverer.deliver(test: "value") }

    context "when delivered successfully" do
      let!(:stub) do
        stub_request(:post, "https://example.com/")
          .with(body: { test: "value" })
          .to_return(status: 200)
      end

      it "calls url" do
        subject
        expect(stub).to have_been_requested
      end
    end

    context "when delivery errored" do
      let!(:stub) do
        stub_request(:post, "https://example.com/")
          .with(body: { test: "value" })
          .to_return(status: 500)
      end

      it "raises Faraday::ServerError" do # rubocop:disable RSpec/MultipleExpectations
        expect { subject }.to raise_error(Faraday::ServerError)
        expect(stub).to have_been_requested
      end
    end
  end
end
