
class GwanaUpdateRequest < ApplicationRecord
  # Enums
  enum :status, {
    pending: 0,
    approved: 1,
    rejected: 2
  }

  # Associations
  belongs_to :gwana, class_name: "Gwana"
  belongs_to :reviewed_by, class_name: "User", optional: true
  has_one_attached :photo

  # Validations
  validates :gwana_id, presence: true
  validates :status, presence: true
  validate :bio_or_photo_present

  # Scopes
  scope :pending, -> { where(status: :pending) }
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def approve!(reviewer:)
    update(
      status: :approved,
      reviewed_by: reviewer,
      reviewed_at: Time.current
    )
  end

  def reject!(reviewer:)
    update(
      status: :rejected,
      reviewed_by: reviewer,
      reviewed_at: Time.current
    )
  end

  def has_bio_update?
    return false if bio.blank?
    return true if gwana.bio.blank?
    
    bio != gwana.bio
  end

  def has_photo_update?
    photo.attached?
  end

  private

  def bio_or_photo_present
    return if bio.present? || photo.attached?

    errors.add(:base, "Au moins la bio ou la photo doit être présente")
  end
end

