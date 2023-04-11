class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :logged_in?

  private

  def logged_in?
    current_user != nil
  end
  def current_user
    @current_user ||= session["user"] ? User.find_by(email: session["user"]["email"]) : nil
  end
end
