class FullTracebackLogger
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      @app.call(env)
    rescue Exception => e
      Rails.logger.error "Full Traceback:\n#{e.full_message(highlight: false)}"
      raise e
    end
  end
end
