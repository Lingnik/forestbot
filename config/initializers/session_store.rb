# config/initializers/session_store.rb

require 'redis-rails'

Rails.application.config.session_store :redis_store,
                                       servers: [
                                         {
                                           url: ENV['REDIS_URL'],
                                           db: 0,
                                           namespace: 'session'
                                         }
                                       ],
                                       key: '_my_app_session',
                                       serializer: :json,

                                       expire_after: 1.day
