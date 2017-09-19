class PlaylistSession < ApplicationRecord
  serialize :members, Array
  belongs_to :user
  validates :user, :name,  presence: true
  validates :is_completed, exclusion: { in: [nil] }
  validates :spotify_id, uniqueness: true
end
