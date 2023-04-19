# app/models/user.rb
# frozen_string_literal: true

# User is the model for a user of the application. It is used to
# authenticate users and to store their Google OAuth tokens, which
# are used to log into the app, and to access Google Drive.
class User < ApplicationRecord
  has_secure_password
  # attr_encrypted :google_token, key: ENV['ATTR_ENCRYPTED_KEY']
  # attr_encrypted :google_refresh_token, key: ENV['ATTR_ENCRYPTED_KEY']
  # attr_encrypted :google_token_expires_at, key: ENV['ATTR_ENCRYPTED_KEY']

  validates :uid, presence: true
  validates :name, presence: true
  validates :email, presence: true, format: {
    with: /\A[\w+\-.]+@cfs\.eco\z/i,
    message: "must be from the cfs.eco domain"
  }
  validates :password_digest, presence: true
  validates :provider, presence: true

  has_many :forest_projects, dependent: :destroy

  def update_tokens(auth)
    entry_dbg
    dbg "google_token: #{auth.credentials.token}"
    dbg "google_token_expires_at: #{Time.at(auth.credentials.expires_at).utc}"
    dbg "google_refresh_token: #{auth.credentials.refresh_token}"
    self.google_token = auth.credentials.token
    self.google_token_expires_at = Time.at(auth.credentials.expires_at).utc
    if google_refresh_token.blank?
      self.google_refresh_token = auth.credentials.refresh_token
    end
    save
  end

  def refresh_tokens!
    entry_dbg
    # Is the users token expired?
    if google_token_expires_at.to_datetime.past?
      oauth = OmniAuth::Strategies::GoogleOauth2.new(
        nil, # App - nil seems to be ok?!
        ENV.fetch("GOOGLE_CLIENT_ID"),
        ENV.fetch("GOOGLE_CLIENT_SECRET")
      )
      token = OAuth2::AccessToken.new(
        oauth.client,
        Time.at(google_token_expires_at).utc.to_s,
        {refresh_token: google_refresh_token}
      )
      new_token = token.refresh!
      if new_token.present?
        update(
          google_token: new_token.token,
          google_token_expires_at: Time.at(new_token.expires_at).utc,
          google_refresh_token: google_refresh_token || new_token.refresh_token
        )
        dbg "Refreshed expired user token"
      else
        warn "User refresh did not work, time to clear the session and force a re-auth."
        # destroy
      end
    end
    google_token
  end
end
