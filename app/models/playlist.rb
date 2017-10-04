class Playlist < ApplicationRecord
  serialize :members, Array
  belongs_to :user
  validates :user, :name, presence: true
  validates :spotify_id, uniqueness: true, :allow_blank => true

  before_validation do
    self.is_completed  = false if self.is_completed.blank?
  end
end
