class User < ApplicationRecord
  include PgSearch::Model

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable

  # Enums
  enum :profile, { user: 0, admin: 1, gwana: 2 }, default: :user
  enum :gender, { male: 0, female: 1, other: 2 }, default: :female

  # Associations
  has_one :gwana_profile, class_name: "Gwana", dependent: :destroy
  has_many :mentorship_requests_as_requester, class_name: "MentorshipRequest", foreign_key: "requester_id", dependent: :destroy
  has_many :mentorship_requests_as_mentor, class_name: "MentorshipRequest", foreign_key: "mentor_id", dependent: :destroy
  has_many :articles, foreign_key: :author_id, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true, uniqueness: true, format: { with: /\A\d{8,15}\z/ }, if: :phone?
  validates :country_code, presence: true, format: { with: /\A\+?\d{1,4}\z/ }, if: :phone?
  validates :profile, :first_name, :last_name, presence: true

  # Callbacks
  before_validation :normalize_phone, if: :phone?
  before_validation :normalize_country_code, if: :country_code?

  # Scopes
  scope :active, -> { where(deleted_at: nil) }
  scope :soft_deleted, -> { where.not(deleted_at: nil) }
  scope :verified, -> { where(is_verified: true) }
  scope :unverified, -> { where(is_verified: false) }

  # Full-text search
  pg_search_scope :search_full_text,
                  against: {
                    phone: "A",
                    email: "A",
                    first_name: "B",
                    last_name: "B"
                  },
                  using: {
                    tsearch: { any_word: true, prefix: true }
                  }

  # Helper methods
  def admin?
    profile == "admin"
  end

  def gwana?
    profile == "gwana"
  end

  def user?
    profile == "user"
  end

  def full_name
    return email if first_name.blank? && last_name.blank?
    [first_name, last_name].compact.join(" ")
  end

  def active_for_authentication?
    super && has_not_been_disabled?
  end

  def inactive_message
    has_not_been_disabled? ? super : "Votre compte est désactivé. Veuillez contacter l'administrateur"
  end

  def has_not_been_disabled?
    deleted_at.nil?
  end

  def soft_deleted?
    deleted_at.present?
  end

  def active?
    deleted_at.nil?
  end

  def soft_delete!
    update_column(:deleted_at, Time.current)
  end

  def restore!
    update_column(:deleted_at, nil)
  end

  def self.find_for_database_authentication(warden_conditions = {})
    conditions = warden_conditions.dup
    login = conditions.delete(:login) || conditions.delete(:email) || warden_conditions[:login]
    
    return nil if login.blank?
    
    where(conditions.to_h).where(
      "lower(email) = :value OR phone = :value",
      { value: login.to_s.strip.downcase }
    ).first
  end

  private

  def normalize_phone
    self.phone = phone.gsub(/\D/, "") if phone.present?
  end

  def normalize_country_code
    self.country_code = country_code.gsub(/[^\d+]/, "") if country_code.present?
    self.country_code = "+#{country_code}" unless country_code&.start_with?("+")
  end
end
