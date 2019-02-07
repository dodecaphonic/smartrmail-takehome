# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.1"

gem "pg", ">= 0.18", "< 2.0"
gem "puma", "~> 3.11"
gem "rails", "~> 5.2.2"
gem "sass-rails", "~> 5.0"
gem "uglifier", ">= 1.3.0"
gem "webpacker"

gem "jbuilder", "~> 2.5"
gem "turbolinks", "~> 5"

gem "bootsnap", ">= 1.1.0", require: false

gem "dry-monads", "~> 1.2.0"
gem "dry-struct", "~> 0.6.0"
gem "dry-types", "~> 0.14.0"

gem "http", "~> 4.0.3"
gem "sucker_punch", "~> 2.0"

group :development, :test do
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
  gem "rspec-rails", "~> 3.8.0"
  gem "rubocop"
  gem "vcr", "~> 4.0.0"
  gem "webmock", "~> 3.5.1"
end

group :development do
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "spring"
  gem "spring-commands-rspec"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", ">= 3.3.0"
end

gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
