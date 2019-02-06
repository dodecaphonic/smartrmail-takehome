# frozen_string_literal: true

require "dry/monads/result"
require "dry/monads/try"
require "dry-struct"
require "json"

require_relative "../models/types"
require_relative "../models/exchange_rate"

# Parses Intraday Time Series data from Alpha Vantage.
class ParseIntradayTimeSeries
  include Dry::Monads::Try::Mixin

  # @param data [String] a string containing raw JSON data
  # @return [Dry::Monads::Result<StandardError, Array<ExchangeRate>>]
  def call(data)
    parse_json(data)
      .bind(&method(:extract_metadata))
      .bind(&method(:build_time_series))
      .fmap { |series| series.sort_by(&:point_in_time) }
  end

  private

  def parse_json(data)
    Try { JSON.parse(data) }.to_result
  end

  def extract_metadata(data)
    Try do
      metadata = Metadata.new(
        from_currency: data.dig("Meta Data", "2. From Symbol"),
        to_currency: data.dig("Meta Data", "3. To Symbol"),
        timezone: data.dig("Meta Data", "7. Time Zone")
      )

      [metadata, data["Time Series FX (5min)"]]
    end.to_result
  end

  def build_time_series((metadata, series))
    Try do
      series.map do |point_in_time, values|
        ExchangeRate.new(massage_exchange_rate(metadata, point_in_time, values))
      end
    end.to_result
  end

  def massage_exchange_rate(metadata, point_in_time, values)
    values
      .transform_keys { |k| k.sub(/\A\d\.\s/, "") }
      .merge(from_currency: metadata.from_currency,
             to_currency: metadata.to_currency,
             point_in_time: parse_datetime(metadata.timezone,
                                           point_in_time))
  end

  def parse_datetime(timezone, datetime)
    match_data = timezone.match(/GMT(?<sign>\+|-)(?<offset>\d+)/)
    suffix = if match_data
               "#{match_data[:sign]}#{match_data[:offset].rjust(2, '0')}:00"
             else
               "Z"
             end

    DateTime.iso8601(datetime.sub(" ", "T") + suffix)
  end

  # Holds the Time Series' metadata.
  class Metadata < Dry::Struct::Value
    attribute :from_currency, Types::Currency
    attribute :to_currency, Types::Currency
    attribute :timezone, Types::Strict::String
  end
end
