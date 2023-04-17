# config/initializers/omniauth.rb

# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Rails.env.development?

  OmniAuth.config.allowed_request_methods = [:post, :get]
  OmniAuth.config.full_host = Rails.configuration.host

  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'], {
    scope: %w[email profile https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/documents],
    prompt: 'select_account',
    hd: 'cfs.eco',
    redirect_uri: "https://#{Rails.configuration.host}/auth/google_oauth2/callback"
  }
end
