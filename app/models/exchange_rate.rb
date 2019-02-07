# frozen_string_literal: true

require "date"
require "dry-struct"

# Holds an exchange rate from BRL to one of the known currencies (USD,
# AUD and EUR).
class ExchangeRate < Dry::Struct::Value
  transform_keys(&:to_sym)

  attribute :point_in_time, Types::Strict::Date | Types::Strict::DateTime
  attribute :from_currency, Types::Currency
  attribute :to_currency, Types::Currency
  attribute :open, Types::Coercible::Float
  attribute :close, Types::Coercible::Float
  attribute :high, Types::Coercible::Float
  attribute :low, Types::Coercible::Float
end
