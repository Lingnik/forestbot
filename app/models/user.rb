# frozen_string_literal: true
#
class User < ApplicationRecord
  has_secure_password
  validates :uid, presence: true
  validates :name, presence: true
  validates :email, presence: true, format: { with: /\A[\w+\-.]+@cfs\.eco\z/i, message: "must be from the cfs.eco domain" }
  validates :provider, presence: true

  def self.from_omniauth(auth)
    # Only allow users with the cfs.eco domain to sign in
    return unless auth.info.email =~ /\A[\w+\-.]+@cfs\.eco\z/i

    User.find_or_create_by(uid: response[:uid], provider: response[:provider]) do |u|
      u.name = auth.info.name
      u.email = auth.info.name
      u.password = SecureRandom.hex
    end
  end
end
