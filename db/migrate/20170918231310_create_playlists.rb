class CreatePlaylists < ActiveRecord::Migration[5.1]
  def change
    create_table :playlists do |t|
      t.references :user, foreign_key: true
      t.string :name
      t.string :spotify_id
      t.string :description
      t.boolean :is_completed
      t.string :members
      t.timestamps
    end
  end
end
