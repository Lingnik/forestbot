# frozen_string_literal: true
#
class User < ApplicationRecord
  has_secure_password
  validates :uid, presence: true
  validates :name, presence: true
  validates :email, presence: true, format: { with: /\A[\w+\-.]+@cfs\.eco\z/i, message: "must be from the cfs.eco domain" }
  validates :provider, presence: true

  def self.from_omniauth(auth)
    puts '!' * 80
    puts auth
    puts '!' * 80
    return unless auth.present?
    return unless auth.info.email.downcase.end_with?("@cfs.eco")

    User.find_or_create_by(email: auth.info.email) do |u|
      u.uid = auth.uid
      u.provider = auth.provider
      u.name = auth.info.name
      u.email = auth.info.email
      u.password = SecureRandom.hex
    end
  end
end
