# config/initializers/redis.rb
# frozen_string_literal: true

$redis = Redis.new( # rubocop:disable Style/GlobalVars
  url: ENV.fetch("REDIS_URL", nil),
  ssl_params: {
    verify_mode: OpenSSL::SSL::VERIFY_NONE
  }
)
