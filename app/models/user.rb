class User < ApplicationRecord
  validates :spotify_id, :access_token, presence: true
  validates :spotify_id, uniqueness: true
end
