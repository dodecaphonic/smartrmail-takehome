# frozen_string_literal: true

require "spec_helper"

require_relative "../../app/services/parse_intraday_time_series"

RSpec.describe ParseIntradayTimeSeries, type: :service do
  context "with parseable data" do
    let(:time_series) { subject.call(raw_data).value! }

    let(:raw_data) do
      File.read(File.expand_path("../fixtures/rates/intraday.json", __dir__))
    end

    it "defines currencies correctly" do
      expect(time_series.map(&:from_currency)).to all(eq("EUR"))
      expect(time_series.map(&:to_currency)).to all(eq("USD"))
    end

    it "is ordered in time from least to most recent" do
      ordered = time_series.each_cons(2)
                           .all? { |(a, b)| a.point_in_time < b.point_in_time }
      expect(ordered).to be(true)
    end
  end

  context "with bad JSON" do
    let(:time_series) { subject.call("/./.jbadjson") }

    it "returns a Failure wrapping the error" do
      expect(time_series).to be_failure
      expect(time_series.failure).to be_kind_of(JSON::ParserError)
    end
  end
end
