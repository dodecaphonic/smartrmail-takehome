# frozen_string_literal: true

require "dry-types"

# Types for the type lords
module Types
  include Dry::Types.module

  Currency = Types::Strict::String.constrained(format: /\A(BRL|USD|AUD|EUR)\z/)
end
