# frozen_string_literal: true

class SessionsController < ApplicationController
  def omniauth_callback
    user = User.from_omniauth(request.env['omniauth.auth'])
    puts request.env['omniauth.auth']
    if user.valid?
      session[:user] = user
      redirect_to root_path, notice: "Signed in successfully!"
    else
      redirect_to root_path, alert: "You must log in with a valid cfs.eco email address"
    end
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
