class Company < ApplicationRecord
  include Sluggable

  belongs_to :user
  has_many :job_applications, dependent: :destroy

  validates :name, presence: true
end
