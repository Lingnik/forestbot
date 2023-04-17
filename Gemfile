source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.1"
gem "rails", "~> 7.0.4", ">= 7.0.4.3"

gem "sprockets-rails"
gem "pg", "~> 1.1"
gem "puma", "~> 6.2"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false

# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

################################################################################
# forestbot
gem "omniauth"
gem "omniauth-google-oauth2"
# gem "omniauth-rails_csrf_protection"
gem "rack-cors"
gem "google-apis-drive_v3"
gem "google-apis-sheets_v4"
gem "google-apis-docs_v1"
gem 'google-apis-core'
# gem "googleauth"
gem "activerecord-session_store"
gem 'redis-rails'
# gem 'attr_encrypted'
# gem "importmap-rails", "~> 1.1"

# 5.0 doesn't work with session state storage crap
gem "redis", "~> 4.8.1", "< 5"

# Store activestorage files in postgres:
#   rails active_storage:install
#   rails active_storage:postgresql:install
#   rails db:migrate
# see config in https://github.com/lsylvester/active_storage-postgresql
gem 'active_storage-postgresql'

################################################################################

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end
