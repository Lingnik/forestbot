# frozen_string_literal: true
require 'googleauth'
require 'googleauth/stores/redis_token_store'

# OAuth2 flow:
# 1. User clicks "Sign in with Google" (/google/authorize)
# 2. User is redirected to Google's OAuth2 authorization page
# 3. User authorizes the app
# 4. User is redirected to the app's OAuth2 callback URL (/google/oauth2/callback)
# 5. The app stores the user's credentials in Redis
# 6. The app redirects the user to the page they were trying to access
# 7. The app checks Redis for the user's credentials
# 8. The app uses the user's credentials to access Google APIs
# 9. The app uses the Google APIs to access the user's data

class GoogleController < ApplicationController
  def initialize
    @client_id = Google::Auth::ClientId.new(
      ENV['GOOGLE_CLIENT_ID'],
      ENV['GOOGLE_CLIENT_SECRET']
    )
    @token_store = Google::Auth::Stores::RedisTokenStore.new(
      redis: Redis.new
    )
    @authorizer = Google::Auth::UserAuthorizer.new(
      @client_id,
      %w[https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/documents],
      @token_store,
      '/google/oauth2/callback'
    )
  end

  def authorize(session)
    user_id = session[:user]['uid']
    credentials = @authorizer.get_credentials(user_id)
    if credentials.nil?
      session[:return_to] ||= request.url if request else nil
      redirect @authorizer.get_authorization_url(login_hint: user_id, request: request)
    end
  end

  def authorized?(session)
    user_id = session[:user]['uid']
    credentials = @authorizer.get_credentials(user_id)
    !credentials.nil?
  end

  def oauth2_callback
    target_url = Google::Auth::WebUserAuthorizer.handle_auth_callback_deferred(request)
    redirect target_url
  end
end
