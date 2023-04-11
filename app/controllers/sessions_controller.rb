# frozen_string_literal: true

class SessionsController < ApplicationController
  def omniauth
    user = User.from_omniauth(request.env['omniauth.auth'])
    puts user.inspect
    puts user.valid?
    puts user.errors.inspect
    puts user.errors.full_messages.inspect
    if user.valid?
      session[:user_id] = user.id
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
