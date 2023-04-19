# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.1"

# gem 'googleauth'
# gem 'image_processing', '~> 1.2' # Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem 'importmap-rails', '~> 1.1'
# gem 'kredis' # Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem 'omniauth-rails_csrf_protection'
# gem 'redis', '~> 4.0' # Use Redis adapter to run Action Cable in production
# gem 'sassc-rails' # Use Sass to process CSS
# gem 'attr_encrypted'
gem "activerecord-session_store"
gem "active_storage-postgresql" # https://github.com/lsylvester/active_storage-postgresql
gem "bcrypt", "~> 3.1.7" # Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bootsnap", require: false
gem "google-apis-core"
gem "google-apis-docs_v1"
gem "google-apis-drive_v3"
gem "google-apis-sheets_v4"
gem "importmap-rails" # Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "jbuilder"
gem "omniauth"
gem "omniauth-google-oauth2"
gem "pg", "~> 1.1"
gem "puma", "~> 5.0"
gem "rack-cors"
gem "rails", "~> 7.0.4", ">= 7.0.4.3"
gem "redis", "~> 4.8.1", "< 5" # 5.0 doesn't work with session state storage crap
gem "redis-rails"
gem "rspec-rails", "~> 6.0"
gem "rubocop", require: false
gem "rubocop-rails", require: false
gem "rubocop-rspec", require: false
gem "sprockets-rails"
gem "standard", "~> 1.26"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
gem "yard", "~> 0.9.34"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mingw x64_mingw]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem 'rack-mini-profiler'

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem 'spring'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end
