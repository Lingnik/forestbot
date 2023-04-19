# lib/full_traceback_logger.rb
# frozen_string_literal: true

# FullTracebackLogger is a Rack middleware that logs the full traceback of
# any exception that is raised in the application.
class FullTracebackLogger
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue Exception => e # rubocop:disable Lint/RescueException
    Rails.logger.error "Full Traceback:\n#{e.full_message(highlight: false)}"
    raise e
  end
end
