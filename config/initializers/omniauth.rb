# frozen_string_literal: true

# config/initializers/omniauth.rb

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Rails.env.development?
  OmniAuth.config.allowed_request_methods = [:post, :get]

  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'], {
    scope: %w[email profile],
    prompt: 'select_account'
  }
end
