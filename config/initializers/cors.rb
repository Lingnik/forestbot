# config/initializers/cors.rb
# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins %w[https://forestbot.herokuapp.com https://forestbot.cfs.eco]

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      credentials: true
  end
end
