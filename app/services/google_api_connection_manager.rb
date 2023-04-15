# app/services/google_api_connection_manager.rb

class GoogleApiConnectionManager

  def initialize(user_id)
    @user_id = user_id
    @client_id = Google::Auth::ClientId.new(
      ENV['GOOGLE_CLIENT_ID'],
      ENV['GOOGLE_CLIENT_SECRET']
    )
    @token_store = Google::Auth::Stores::RedisTokenStore.new(
      redis: Redis.new
    )
  end

  def authorizer
    @authorizer ||= Google::Auth::UserAuthorizer.new(
      @client_id,
      %w[https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/documents],
      @token_store,
      '/google/oauth2/callback'
    )
  end

  def credentials
    authorizer.get_credentials(@user_id)
  end
end
