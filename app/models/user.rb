class User < ApplicationRecord
  has_secure_password

  has_many :companies,        dependent: :destroy
  has_many :job_applications, dependent: :destroy
  has_many :follow_ups,       dependent: :destroy

  before_save :downcase_email

  validates :email,
            presence:   true,
            uniqueness: { case_sensitive: false },
            format:     { with: URI::MailTo::EMAIL_REGEXP, message: "is not a valid email" }

  validates :password,
            presence: true,
            length:   { minimum: 8 },
            if:       :password_digest_changed?

  def self.ransackable_attributes(auth_object = nil)
    ["email", "created_at", "updated_at", "id"]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  private

  def downcase_email
    self.email = email.downcase
  end
end