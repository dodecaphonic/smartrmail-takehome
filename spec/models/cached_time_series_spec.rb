# frozen_string_literal: true

require "rails_helper"

RSpec.describe CachedTimeSeries, type: :model do
  let(:from_currency) { "USD" }
  let(:to_currency) { "BRL" }
  let(:data) do
    Array.new(10) do |i|
      ExchangeRate.new(from_currency: from_currency,
                       to_currency: to_currency,
                       point_in_time: (Time.zone.now - i.minutes).to_datetime,
                       open: (rand * 4).floor,
                       close: (rand * 4).floor,
                       high: (rand * 4).floor,
                       low: (rand * 4).floor)
    end.reverse
  end

  it "serializes and deserializes data correctly" do
    cts = CachedTimeSeries.create!(period: :intraday,
                                   from_currency: from_currency,
                                   to_currency: to_currency,
                                   time_series: data)

    expect(cts.time_series).to all(be_kind_of(ExchangeRate))
    # FIXME: Resorting to JSON because DateTimes are not matching.
    expect(cts.time_series.first.to_json).to eq(data.first.to_json)
  end
end
