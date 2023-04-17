# app/controllers/sessions_controller.rb

# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :omniauth_callback

  def omniauth_callback
    entry_dbg
    user = User.find_or_initialize_by(email: auth.info.email) do |u|
      u.uid = auth.uid
      u.provider = auth.provider
      u.name = auth.info.name
      u.password = SecureRandom.hex
    end
    user.update_tokens(auth)
    session[:user_id] = user.id
    redirect_to root_path, notice: "Signed in successfully!"
  end

  def destroy
    entry_dbg
    session.clear
    redirect_to root_path, notice: "Signed out successfully!"
  end

  protected

  def auth
    entry_dbg
    request.env['omniauth.auth']
  end


end
