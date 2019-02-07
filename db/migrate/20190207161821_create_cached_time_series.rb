# frozen_string_literal: true

class CreateCachedTimeSeries < ActiveRecord::Migration[5.2]
  def change
    create_table :cached_time_series do |t|
      t.string :from_currency, null: false
      t.string :to_currency, null: false
      t.integer :period, null: false
      t.text :time_series, null: false

      t.timestamps
    end
  end
end
