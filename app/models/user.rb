class User < ApplicationRecord
  has_many :playlists
  has_many :members
  validates :spotify_id, :access_token, presence: true
  validates :spotify_id, uniqueness: true
end
