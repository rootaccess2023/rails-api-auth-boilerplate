class FollowUp < ApplicationRecord
  belongs_to :user
  belongs_to :job_application, optional: true

  validates :title, :due_at, presence: true

  scope :open,    -> { where(completed_at: nil) }
  scope :overdue, -> { open.where(due_at: ..Time.current) }
  scope :ordered, -> { order(due_at: :asc) }

  def completed?
    completed_at.present?
  end
end
