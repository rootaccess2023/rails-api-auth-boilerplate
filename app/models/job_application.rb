class JobApplication < ApplicationRecord
  include Sluggable

  belongs_to :user
  belongs_to :company

  enum :status, {
    saved:        0,
    applied:      1,
    screening:    2,
    interviewing: 3,
    offer:        4,
    rejected:     5,
    accepted:     6,
    withdrawn:    7
  }

  validates :role_title, presence: true
end
