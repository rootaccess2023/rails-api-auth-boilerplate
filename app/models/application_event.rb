class ApplicationEvent < ApplicationRecord
  belongs_to :job_application
  belongs_to :user

  before_validation :normalize_event_type

  validates :title, presence: true
  validates :event_type, presence: true, inclusion: { in: %w[assessment interview] }

  private

  def normalize_event_type
    self.event_type = event_type.downcase if event_type.present?
  end
end