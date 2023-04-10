class Users::OmniauthCallbacksController < ApplicationController
  def google_oauth2
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted? && @user.valid?
      # Log the user in and redirect to the appropriate page
      session[:user_id] = @user.id
      redirect_to root_path
      flash[:notice] = "Signed in successfully with Google."
    else
      # Redirect to the sign-in page with an error message
      flash[:alert] = 'Email must be from the cfs.eco domain'
      redirect_to root_path
    end
  end
end
