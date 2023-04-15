# app/controllers/google_controller.rb

# frozen_string_literal: true
require 'googleauth'
require 'googleauth/stores/redis_token_store'
require_relative '../services/google_api_connection_manager'

class GoogleController < ApplicationController

  def authorize(session)
    if !authorized?(session)
      session[:return_to] ||= request.url if request else nil
      redirect connection_manager.authorizer.get_authorization_url(login_hint: @user_id, request: request)
    end
  end

  def authorized?(session)
    unless session && session[:user_id]
      return false
    end
    @user_id = session[:user_id]
    credentials = connection_manager.authorizer.get_credentials(@user_id)
    !credentials.nil?
  end

  def connection_manager
    @connection_manager ||= GoogleApiConnectionManager.new(@user_id)
  end

  def oauth2_callback
    target_url = Google::Auth::WebUserAuthorizer.handle_auth_callback_deferred(request)
    redirect target_url
  end
end
