# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require "dotenv"
require "vcr"

Dotenv.load

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  VCR.configure do |c|
    c.cassette_library_dir = File.expand_path("fixtures/vcr_cassettes", __dir__)
    c.default_cassette_options = { record: :new_episodes }
    c.hook_into :webmock
    c.ignore_localhost = true
  end
end
