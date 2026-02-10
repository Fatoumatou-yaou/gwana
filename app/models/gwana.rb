require "uri"

class Gwana < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidate, use: :slugged

  include PgSearch::Model

  # Associations
  belongs_to :user
  belongs_to :commune, optional: true
  has_many :mentorship_requests_as_mentor, class_name: "MentorshipRequest", foreign_key: "mentor_id"
  has_many :mentorship_requests_as_requester, class_name: "MentorshipRequest", foreign_key: "requester_id"
  has_many :gwana_update_requests, class_name: "GwanaUpdateRequest", dependent: :destroy
  has_many :activities, class_name: "GwanaActivity", dependent: :destroy
  has_many :portrait_videos, class_name: "GwanaPortraitVideo", dependent: :destroy
  has_one_attached :photo

  # Validations
  validates :first_name, :last_name,  presence: true
  validates :user_id, uniqueness: true
  validates :slug, uniqueness: true, allow_nil: true
  validates :phone, format: { with: /\A\d{8}\z/ }, uniqueness: true, allow_blank: true
  validate :validate_url_format
  validate :normalize_phone_before_validation

  # Scopes
  scope :available_for_mentorship, -> { where(available_for_mentorship: true) }
  scope :by_region, ->(region_name) {
    if region_name.present?
      joins(commune: { department: :region })
        .where(regions: { name: region_name })
    end
  }
  scope :by_profession, ->(profession) { where(profession: profession) if profession.present? }

  # Full-text search
  pg_search_scope :search_by_text,
                  against: %i[first_name last_name bio profession skills region],
                  using: {
                    tsearch: { prefix: true }
                  }

  # Instance methods
  def skills_array
    return [] if skills.blank?

    skills.split(",").map(&:strip)
  end

  private

  def normalize_phone_before_validation
    return unless phone.present?
    self.phone = phone.gsub(/\D/, "")
  end

  def validate_url_format
    url_fields = { linkedin_url: linkedin_url, twitter_url: twitter_url, website_url: website_url }
    url_fields.each do |field, value|
      next if value.blank?

      uri = URI.parse(value)
      unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
        errors.add(field, "doit être une URL valide (commençant par http:// ou https://)")
      end
    rescue URI::InvalidURIError
      errors.add(field, "doit être une URL valide")
    end
  end

  def slug_candidate
    "#{first_name} #{last_name}".humanize
  end

  def should_generate_new_friendly_id?
    first_name_changed? || last_name_changed? || slug.blank?
  end
end

