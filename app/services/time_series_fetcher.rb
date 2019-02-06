# frozen_string_literal: true

require "dry/monads/task"

require_relative "../models/types"
require_relative "parse_time_series"

# Fetches Time Series data from Alpha Vantage.
class TimeSeriesFetcher
  include Dry::Monads::Task::Mixin

  ALPHAVANTAGE_URL = "https://www.alphavantage.co/query"

  def initialize(from_currency:, to_currency:,
                 api_key: ENV["ALPHAVANTAGE_API_KEY"])
    @from_currency = Types::Currency[from_currency]
    @to_currency = Types::Currency[to_currency]
    @api_key = api_key
    @parse_time_series = ParseTimeSeries.new
    @http = HTTP.persistent(ALPHAVANTAGE_URL)
  end

  # @return [Task<Result<StandardError, Array<ExchangeRate>>>]
  def fetch_weekly
    fetch(function: "FX_WEEKLY")
  end

  # @return [Task<Result<StandardError, Array<ExchangeRate>>>]
  def fetch_monthly
    fetch(function: "FX_MONTHLY")
  end

  # @return [Task<Result<StandardError, Array<ExchangeRate>>>]
  def fetch_daily
    fetch(function: "FX_DAILY")
  end

  # @return [Task<Result<StandardError, Array<ExchangeRate>>>]
  def fetch_intraday
    fetch(function: "FX_INTRADAY", interval: "5min")
  end

  private

  attr_reader :from_currency, :to_currency, :api_key, :parse_time_series, :http

  def fetch(extra_params = {})
    Task[:io] do
      http
        .get(ALPHAVANTAGE_URL, params: common_options.merge(extra_params))
        .then(&:to_s)
        .then { |data| parse_time_series.call(data) }
    end
  end

  def common_options
    {
      datatype: :json,
      apikey: api_key,
      from_symbol: from_currency,
      to_symbol: to_currency
    }
  end
end
