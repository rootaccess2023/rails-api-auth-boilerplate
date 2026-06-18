module Sluggable
  extend ActiveSupport::Concern

  # Columns tried in order to seed the slug text. First one present on the
  # model wins; falls back to a bare random hex if none match.
  SLUG_SOURCE_CANDIDATES = %i[name title role_title label].freeze

  included do
    before_validation :generate_slug, on: :create
    validates :slug, presence: true, uniqueness: true
  end

  def to_param
    slug
  end

  private

  def generate_slug
    return if slug.present?

    base = SLUG_SOURCE_CANDIDATES
             .find { |f| respond_to?(f) }
             .then { |f| f ? send(f).to_s.strip : "" }

    loop do
      candidate = [base.parameterize.presence, SecureRandom.hex(4)].compact.join("-")
      self.slug = candidate
      break unless self.class.exists?(slug: candidate)
    end
  end
end
