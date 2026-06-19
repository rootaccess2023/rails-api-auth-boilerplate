class StatusChange < ApplicationRecord
  STATUS_VALUES = {
    saved: 0, applied: 1, screening: 2, interviewing: 3,
    offer: 4, rejected: 5, accepted: 6, withdrawn: 7
  }.freeze

  belongs_to :job_application

  # prefix: true avoids method-name collisions between from_status and to_status
  # (both share the same value names). Accessors still return strings: sc.from_status => "applied"
  enum :from_status, STATUS_VALUES, prefix: true
  enum :to_status,   STATUS_VALUES, prefix: true
end
