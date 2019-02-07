# frozen_string_literal: true

require "dry/monads/all"

# Refreshes the CachedTimeSeries, fetching new remote data only if the
# local copy is stale.
class RefreshCachedTimeSeries
  M = Dry::Monads

  include Dry::Monads::Task::Mixin
  include Dry::Monads::Do.for(:call)

  # @return [Task<Result<StandardError,:done>>]
  def call
    yield refresh(:intraday)
    yield refresh(:weekly)
    yield refresh(:monthly)

    refresh(:daily)
  end

  private

  def refresh(period)
    earliest_cached = CachedTimeSeries
                      .public_send(period)
                      .order(:updated_at)
                      .first

    if !earliest_cached || 5.minutes.ago > earliest_cached.updated_at
      fetch(period).fmap(&method(:store).curry.call(period))
    else
      M::Task[:immediate] { :done }
    end
  end

  def store(period, series)
    series.each do |(from_currency, to_currency), values|
      CachedTimeSeries
        .where(from_currency: from_currency, to_currency: to_currency,
               period: period)
        .first_or_initialize
        .update!(time_series: values)
    end

    # Alpha Vantage gives us only 5 requests per minute. We sleep to
    # space them out.
    sleep 60

    :done
  end

  def fetch(period)
    M::List[*fetchers.map { |f| f.public_send("fetch_#{period}") }]
      .typed(M::Task)
      .traverse
      .fmap { |results| results.typed(M::Result).traverse }
      .to_result
      .bind(&:itself)
      .fmap(&method(:as_currency_series_map))
  end

  def as_currency_series_map(results)
    results
      .fmap { |rs| [[rs.first.from_currency, rs.first.to_currency], rs] }
      .value
      .to_h
  end

  def fetchers
    [
      TimeSeriesFetcher.new(from_currency: "USD", to_currency: "BRL"),
      TimeSeriesFetcher.new(from_currency: "EUR", to_currency: "BRL"),
      TimeSeriesFetcher.new(from_currency: "AUD", to_currency: "BRL")
    ]
  end
end
