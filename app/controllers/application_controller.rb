# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :logged_in?
  before_action :authenticate_user!
  before_action :authorize_google

  private

  def authorize_google
    google_service = GoogleController.new
    google_service.authorize(session) unless google_service.authorized?(session)
  end

  def logged_in?
    current_user != nil
  end

  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end

  def authenticate_user!
    redirect_to root_path, alert: 'You need to sign in first!' unless current_user
  end
end
