# frozen_string_literal: true

RSpec.describe NatsStreamer::ParamsRenderer do
  let(:renderer) { described_class.new(subject: subject_name, params:) }

  let(:subject_name) { "foo.bar" }
  let(:params) { { template: "The template, payload=<%= event[:payload] %>" } }

  describe "#render" do
    subject { renderer.render({ payload: "test" }) }

    it "returns rendered parameters" do
      expect(subject).to eq({
                              template: "The template, payload=test",
                              event: { payload: "test" },
                              subject: "foo.bar"
                            })
    end
  end
end
