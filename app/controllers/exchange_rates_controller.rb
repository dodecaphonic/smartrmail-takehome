# frozen_string_literal: true

# Moves ExchangeRates to the beautiful, lovely UI.
class ExchangeRatesController < ApplicationController
  before_action :load_time_series

  def index
    respond_to do |format|
      format.html
      format.json do
        render json: @time_series
      end
    end
  end

  def show
    rate = CachedTimeSeries.latest_rate_for(params[:id])

    respond_to do |format|
      format.json do
        render json: rate
      end
    end
  end

  private

  def load_time_series
    return unless request.format.json?

    @time_series =
      CachedTimeSeries
      .where(from_currency: params[:from_currency] || "USD",
             to_currency: "BRL",
             period: params[:period] || "intraday")
      .first
      &.time_series || []
  end
end
