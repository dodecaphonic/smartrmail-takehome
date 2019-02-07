# frozen_string_literal: true

require "spec_helper"

require_relative "../../app/services/time_series_fetcher"

RSpec::Matchers.define :be_at_least_within_minutes do |expected|
  match do |data|
    # rubocop:disable Rails/Date
    data.map { |r| r.point_in_time.to_time }
        .each_cons(2)
        .map { |(a, b)| (b - a) / 60.0 }
        .all? { |i| i >= expected }
    # rubocop:enable Rails/Date
  end

  failure_message do |_|
    "expected ExchangeRates to be within #{expected} minutes of one another"
  end
end

RSpec.describe TimeSeriesFetcher, type: :service do
  let(:from_currency) { "USD" }
  let(:to_currency) { "BRL" }

  subject do
    described_class.new(from_currency: from_currency,
                        to_currency: to_currency)
  end

  describe "#intraday" do
    it "fetches data from a day with 5 minute intervals" do
      VCR.use_cassette("time_series_fetcher_intraday") do
        data = subject.fetch_intraday.value!.value!
        expect(data).to be_at_least_within_minutes(5.0)
      end
    end
  end

  describe "#daily" do
    it "fetches data spaced in days" do
      VCR.use_cassette("time_series_fetcher_daily") do
        data = subject.fetch_daily.value!.value!
        expect(data).to be_at_least_within_minutes(24 * 60)
      end
    end
  end

  describe "#weekly" do
    it "fetches data spaced in days" do
      VCR.use_cassette("time_series_fetcher_weekly") do
        data = subject.fetch_daily.value!.value!
        expect(data).to be_at_least_within_minutes(24 * 60)
      end
    end
  end

  describe "#monthly" do
    it "fetches data spaced in days" do
      VCR.use_cassette("time_series_fetcher_monthly") do
        data = subject.fetch_daily.value!.value!
        expect(data).to be_at_least_within_minutes(24 * 60)
      end
    end
  end

  it "fails when built with an unknown currency" do
    expect { described_class.new(from_currency: "BRL", to_currency: "NLG") }
      .to raise_error(Dry::Types::ConstraintError)
    expect { described_class.new(from_currency: "NLG", to_currency: "BRL") }
      .to raise_error(Dry::Types::ConstraintError)
  end
end
