class User < ApplicationRecord
  has_many :playlists
  validates :spotify_id, :access_token, presence: true
  validates :spotify_id, uniqueness: true
end
