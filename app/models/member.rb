# frozen_string_literal: true

require "uri"

class Member < ApplicationRecord
  extend FriendlyId
  friendly_id :full_name, use: :slugged

  include PgSearch::Model

  # Associations
  belongs_to :user
  has_one_attached :photo
  has_many :mentorship_requests_as_mentor, class_name: "MentorshipRequest", foreign_key: "mentor_id", dependent: :destroy
  has_many :mentorship_requests_as_requester, class_name: "MentorshipRequest", foreign_key: "requester_id", dependent: :destroy

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :user_id, uniqueness: true
  validates :slug, uniqueness: true, allow_nil: true
  validate :validate_url_format

  private

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

  # Scopes
  scope :available_for_mentorship, -> { where(available_for_mentorship: true) }
  scope :by_region, ->(region) { where(region: region) if region.present? }
  scope :by_profession, ->(profession) { where(profession: profession) if profession.present? }

  # Full-text search
  pg_search_scope :search_by_text,
                  against: %i[first_name last_name bio profession skills region],
                  using: {
                    tsearch: { prefix: true }
                  }

  # Instance methods
  def full_name
    "#{first_name} #{last_name}".strip
  end

  def skills_array
    return [] if skills.blank?

    skills.split(",").map(&:strip)
  end


  def should_generate_new_friendly_id?
    first_name_changed? || last_name_changed? || slug.blank?
  end
end
