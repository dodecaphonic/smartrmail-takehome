# frozen_string_literal: true

require "dry/monads/all"

# Runs RefreshCachedTimeSeries in the background.
class RefreshCachedTimeSeriesJob < ApplicationJob
  def perform
    RefreshCachedTimeSeries.new.call
  end
end
