require "uri"

class GwanaNetworkRequest < ApplicationRecord
  include Draper::Decoratable
  # Enums
  enum :status, {
    pending: 0,
    approved: 1,
    rejected: 2
  }

  # Associations
  belongs_to :commune, optional: true
  belongs_to :reviewed_by, class_name: "User", optional: true
  has_one_attached :identity_document
  has_one_attached :photo

  # Validations
  validates :first_name, :last_name, :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :phone, format: { with: /\A\d{8}\z/ }, uniqueness: true, allow_blank: true
  validates :profession, :experiences, :formations, :bio, presence: true
  validates :identity_document, presence: true
  validates :photo, presence: true
  validate :identity_document_must_be_pdf
  validate :validate_url_format
  validate :rejection_reason_present_if_rejected
  validate :normalize_phone_before_validation
  validate :email_not_already_in_use

  # Scopes
  scope :pending, -> { where(status: :pending) }
  scope :recent, -> { order(created_at: :desc) }
  scope :expired, -> { where(status: :pending).where("created_at < ?", 1.month.ago) }

  # Instance methods
  def approve!(reviewer:)
    update(
      status: :approved,
      reviewed_by: reviewer,
      reviewed_at: Time.current
    )
  end

  def reject!(reviewer:, reason:)
    update(
      status: :rejected,
      reviewed_by: reviewer,
      reviewed_at: Time.current,
      rejection_reason: reason
    )
  end

  def expired?
    pending? && created_at < 1.month.ago
  end

  def full_name
    [first_name, last_name].compact.join(" ")
  end

  private

  def normalize_phone_before_validation
    return unless phone.present?
    self.phone = phone.gsub(/\D/, "")
  end

  def identity_document_must_be_pdf
    return unless identity_document.attached?

    unless identity_document.content_type == "application/pdf"
      errors.add(:identity_document, "doit être un fichier PDF")
    end
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

  def rejection_reason_present_if_rejected
    if rejected? && rejection_reason.blank?
      errors.add(:rejection_reason, "doit être rempli lors du rejet")
    end
  end

  def email_not_already_in_use
    return unless email.present?
    
    if User.exists?(email: email)
      errors.add(:email, "a déjà été utilisé")
    end
  end

end

