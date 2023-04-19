# config/initializers/session_store.rb
# frozen_string_literal: true

require "redis-rails"

Rails.application.config.session_store(
  :redis_store,
  servers: [
    {
      url: ENV.fetch("REDIS_URL", nil),
      ssl_params: {verify_mode: OpenSSL::SSL::VERIFY_NONE},
      db: 0,
      namespace: "session"
    }
  ],
  key: "_my_app_session",
  serializer: :json,
  expire_after: 1.day
)
