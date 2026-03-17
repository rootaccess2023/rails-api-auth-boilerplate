class User < ApplicationRecord
  has_secure_password

  before_save :downcase_email

  validates :email,
            presence:   true,
            uniqueness: { case_sensitive: false },
            format:     { with: URI::MailTo::EMAIL_REGEXP }

  validates :password,
            presence: true,
            length:   { minimum: 8 },
            if:       :password_digest_changed?

  private

  def downcase_email
    self.email = email.downcase
  end
end