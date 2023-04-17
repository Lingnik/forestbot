# app/models/user.rb

class User < ApplicationRecord
  has_secure_password
  #attr_encrypted :google_token, key: ENV['ATTR_ENCRYPTED_KEY']
  #attr_encrypted :google_refresh_token, key: ENV['ATTR_ENCRYPTED_KEY']
  #attr_encrypted :google_token_expires_at, key: ENV['ATTR_ENCRYPTED_KEY']

  validates :uid, presence: true
  validates :name, presence: true
  validates :email, presence: true, format: { with: /\A[\w+\-.]+@cfs\.eco\z/i, message: "must be from the cfs.eco domain" }
  validates :password_digest, presence: true
  validates :provider, presence: true

  has_many :forest_projects, dependent: :destroy

  def update_tokens(auth)
    entry_dbg
    self.google_token = auth.credentials.token
    self.google_token_expires_at = Time.at(auth.credentials.expires_at)
    self.google_refresh_token = auth.credentials.refresh_token unless self.google_refresh_token.present?
    save
  end

  def refresh_tokens!
    entry_dbg
    # Is the users token expired?
    if self.google_token_expires_at.to_datetime.past?
      oauth = OmniAuth::Strategies::GoogleOauth2.new(
        nil, # App - nil seems to be ok?!
        ENV['GOOGLE_CLIENT_ID'],
        ENV['GOOGLE_CLIENT_SECRET']
      )
      token = OAuth2::AccessToken.new(
        oauth.client,
        Time.at(self.google_token_expires_at),
        { refresh_token: self.google_refresh_token }
      )
      new_token = token.refresh!
      if new_token.present?
        self.update(
          google_token: new_token.token,
          google_token_expires_at: Time.at(new_token.expires_at),
          google_refresh_token: self.google_refresh_token || new_token.refresh_token
        )
        dbg "Refreshed expired user token"
      else
        warn "User refresh did not work, time to clear the session and force a re-auth."
        #destroy
      end
    end
    self.google_token
  end
end
