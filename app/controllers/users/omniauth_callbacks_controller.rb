# frozen_string_literal: true
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      # Perform a simple check to verify the user is in a list of approved users.
      # Replace `approved_users` with an array of allowed email addresses or
      # implement your own logic for checking approved users.
      approved_users = ['ruth@cfs.eco']
      if approved_users.include?(@user.email)
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: 'Google') if is_navigational_format?
      else
        flash[:alert] = 'Not authorized.'
        redirect_to new_user_session_path
      end
    else
      session['devise.google_data'] = request.env['omniauth.auth'].except('extra')
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end
end
