# frozen_string_literal: true

# Caches results from Alpha Vantage.
class CachedTimeSeries < ApplicationRecord
  enum period: { intraday: 0, daily: 1, weekly: 2, monthly: 3 }

  validates :from_currency, :to_currency, :period, :time_series,
            presence: true

  serialize :time_series, JSON

  def self.latest_rate_for(currency)
    intraday
      .find_by(from_currency: currency)
      &.time_series
      &.last
  end

  def time_series
    self["time_series"].map do |er|
      ExchangeRate.new(
        er.merge("point_in_time" => DateTime.iso8601(er.fetch("point_in_time")))
      )
    end
  end
end
