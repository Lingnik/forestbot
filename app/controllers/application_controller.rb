# app/controllers/application_controller.rb
# frozen_string_literal: true

# ApplicationController is the base class for all controllers in this application.
# It provides methods that are available to all controllers.
# We are using it to globally require authentication for all controllers.
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :logged_in?
  before_action :authenticate_user!

  skip_before_action :authenticate_user!, only: %i[omniauth_callback index destroy] # rubocop:disable Rails/LexicallyScopedActionFilter

  private

  # Check if user is logged in
  def logged_in?
    entry_dbg
    current_user != nil
  end

  # Current oauth user
  def current_user
    entry_dbg
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # Ensure user is logged in before allowing them to access a page
  def authenticate_user!
    entry_dbg
    logged_in? ? true : redirect_to(root_path, alert: "You need to sign in first!")
  end
end
