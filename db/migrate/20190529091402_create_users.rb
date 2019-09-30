class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :login_digest, null: false
      t.string :password_digest, null: false
      # mobile auth
      t.string :authentication_token

      ## Rememberable
      t.string :remember_digest

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :sign_in_at
      t.inet     :sign_in_ip

      ## Confirmable
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at

      ## searchable
      t.string :nick

      t.timestamps
    end

    add_index :users, :login_digest, unique: true
    add_index :users, :nick, unique: true
  end
end
