# frozen_string_literal: true

require "spec_helper"

require_relative "../../app/models/types"
require_relative "../../app/models/exchange_rate"

RSpec.describe ExchangeRate, type: :model do
  let(:raw_data) do
    {
      point_in_time: Time.now.utc.to_datetime,
      from_currency: "USD",
      to_currency: "BRL",
      open: 3.6934,
      close: 3.6958,
      high: 3.6927,
      low: 3.6947
    }
  end

  it "gets built from raw data correctly" do
    rate = ExchangeRate.new(raw_data)

    expect(rate.open).to eq(raw_data[:open])
    expect(rate.close).to eq(raw_data[:close])
    expect(rate.high).to eq(raw_data[:high])
    expect(rate.low).to eq(raw_data[:low])
  end

  it "works with known currencies" do
    %w[BRL USD AUD EUR].each do |currency|
      expect { ExchangeRate.new(raw_data.merge(from_currency: currency)) }
        .not_to raise_error
      expect { ExchangeRate.new(raw_data.merge(to_currency: currency)) }
        .not_to raise_error
    end
  end

  it "fails when created with an unknown currency" do
    expect { ExchangeRate.new(raw_data.merge(from_currency: "NLG")) }
      .to raise_error(Dry::Struct::Error)
    expect { ExchangeRate.new(raw_data.merge(to_currency: "NLG")) }
      .to raise_error(Dry::Struct::Error)
  end

  it "transforms string keys to symbols" do
    expect { ExchangeRate.new(raw_data.transform_keys(&:to_s)) }
      .not_to raise_error
  end

  it "coerces numerical data from strings" do
    rate = ExchangeRate.new(
      raw_data.transform_values(&:to_s)
              .merge(point_in_time: raw_data[:point_in_time])
    )

    expect(rate.open).to eq(raw_data[:open])
    expect(rate.close).to eq(raw_data[:close])
    expect(rate.high).to eq(raw_data[:high])
    expect(rate.low).to eq(raw_data[:low])
  end
end
