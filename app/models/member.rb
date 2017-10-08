class Member < ApplicationRecord
  belongs_to :user
  belongs_to :playlist
  attr_accessor :user_spotify_id
end
