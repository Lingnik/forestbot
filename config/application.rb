# config/application.rb
# frozen_string_literal: true

require_relative "boot"
require "rails/all"
# require "attr_encrypted"

# Limit this to when the app is running in development mode
require_relative "../lib/full_traceback_logger" if Rails.env.development? || ENV.fetch("DEBUG", "") == "*"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Forestbot
  # The Application class is the main entry point for the Rails application.
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.session_store :cookie_store, key: "_interslice_session"
    config.middleware.use ActionDispatch::Cookies # Required for all session management
    # config.middleware.use ActionDispatch::Session::CookieStore, config.session_options

    # config.middleware.insert_before 0, Rack::Cors do
    #   allow do
    #     origins "https://forestbot.herokuapp.com"
    #     resource "*",
    #              headers: :any,
    #              methods: %i[get post put patch delete options head],
    #              credentials: true
    #   end
    # end

    config.middleware.use(FullTracebackLogger) if Rails.env.development? || ENV.fetch("DEBUG", "") == "*"
  end
end
