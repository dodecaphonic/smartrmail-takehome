# frozen_string_literal: true

require "dry/monads/result"
require "dry/monads/try"
require "dry-struct"
require "json"

require_relative "../models/types"
require_relative "../models/exchange_rate"

# Parses Time Series data from Alpha Vantage.
class ParseTimeSeries
  include Dry::Monads::Try::Mixin
  include Dry::Monads::Result::Mixin

  # @param data [String] a string containing raw JSON data
  # @return [Dry::Monads::Result<StandardError, Array<ExchangeRate>>]
  def call(data)
    parse_json(data)
      .bind(&method(:fail_on_bad_data))
      .bind(&method(:extract_metadata))
      .bind(&method(:build_time_series))
      .fmap { |series| series.sort_by(&:point_in_time) }
  end

  private

  def fail_on_bad_data(data)
    if data["Meta Data"]
      Success(data)
    else
      Failure(StandardError.new("Missing time series metadata"))
    end
  end

  def parse_json(data)
    Try { JSON.parse(data) }.to_result
  end

  def extract_metadata(data)
    Try do
      metadata = Metadata.new(
        from_currency: dig_matching(data["Meta Data"], /From Symbol/),
        to_currency: dig_matching(data["Meta Data"], /To Symbol/),
        timezone: dig_matching(data["Meta Data"], /Time Zone/)
      )

      [metadata, dig_matching(data, /Time Series/)]
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
    hour_part = datetime.size > 10 ? "" : "T00:00:00"

    DateTime.iso8601(datetime.sub(" ", "T") +
                     hour_part +
                     timezone_suffix(timezone))
  end

  def timezone_suffix(timezone)
    if (match_data = timezone.match(/GMT(?<sign>\+|-)(?<offset>\d+)/))
      "#{match_data[:sign]}#{match_data[:offset].rjust(2, '0')}:00"
    else
      "Z"
    end
  end

  def dig_matching(data, matcher)
    data.find { |k, _| k =~ matcher }&.last
  end

  # Holds the Time Series' metadata.
  class Metadata < Dry::Struct::Value
    attribute :from_currency, Types::Currency
    attribute :to_currency, Types::Currency
    attribute :timezone, Types::Strict::String
  end
end
