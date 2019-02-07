Concurrent::TimerTask.new(run_now: true) do
  RefreshCachedTimeSeriesJob.perform_later
end.tap(&:execute)
