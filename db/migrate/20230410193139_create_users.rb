class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :uid, null: false
      t.string :name, null: false
      t.string :email, null: false
      t.string :tz, false, default: "America/Los_Angeles"
      t.string :password_digest, null: false

      t.string :provider, null: false
      t.string :google_uid, false
      t.string :google_token, false
      t.string :google_refresh_token, false
      t.datetime :google_token_expires_at


      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
