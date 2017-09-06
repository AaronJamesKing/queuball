class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :display_name
      t.string :spotify_id
      t.string :access_token
      t.string :refresh_token
      t.integer :expires_in
      t.datetime :authorized_at

      t.timestamps
    end
  end
end
