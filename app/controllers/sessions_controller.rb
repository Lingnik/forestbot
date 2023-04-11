# frozen_string_literal: true

class SessionsController < ApplicationController
  def omniauth
    user = User.from_omniauth(request.env['omniauth.auth'])
    if user.valid?
      session[:user_id] = user.id
      redirect_to root_path, notice: "Signed in successfully!"
    else
      redirect_to '/login'
    end
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
