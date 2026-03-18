class JobApplication < ApplicationRecord
  include Sluggable

  belongs_to :user
  has_many :application_events, dependent: :destroy

  STAGES = %w[Prospect Applied In\ Process Offer Rejected Archived].freeze

  validates :stage, inclusion: { in: STAGES }
end