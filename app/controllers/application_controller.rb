# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :logged_in?
  before_action :authenticate_user!

  skip_before_action :authenticate_user!, only: [:omniauth_callback, :index, :login]

  private

  # Check if user is logged in
  def logged_in?
    entry_dbg
    current_user != nil
  end

  # Current oauth user
  def current_user
    entry_dbg
    @current_user ||= User.find_by_id(session[:user_id])
  end

  # Ensure user is logged in before allowing them to access a page
  def authenticate_user!
    entry_dbg
    unless logged_in?
      redirect_to root_path, alert: 'You need to sign in first!'
    end
  end
end
