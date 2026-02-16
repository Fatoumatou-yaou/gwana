class GwanaActivity < ApplicationRecord
  include Draper::Decoratable

  belongs_to :gwana
  has_many_attached :photos

  # Enums
  enum :activity_type, {
    formation: "formation",
    seminaire: "seminaire",
    caravane: "caravane",
    atelier: "atelier",
    sensibilisation: "sensibilisation",
    mentorat: "mentorat",
    autre: "autre"
  }, default: "autre"

  # Validations
  validates :activity_type, presence: true
  validates :activity_date, presence: true
  validates :description, presence: true, length: { minimum: 10 }
  validate :must_have_media
  validate :activity_date_not_after_today

  # Scopes
  scope :recent, -> { order(activity_date: :desc, created_at: :desc) }
  scope :by_type, ->(type) { where(activity_type: type) if type.present? }
  scope :with_video, -> { where.not(youtube_video_id: nil) }

  # Instance methods
  def has_video?
    youtube_video_id.present?
  end

  def has_photos?
    photos.attached?
  end

  def has_media?
    has_video? || has_photos?
  end

  def youtube_embed_url
    return nil unless youtube_video_id.present?
    "https://www.youtube.com/embed/#{youtube_video_id}"
  end

  def youtube_thumbnail_url
    return nil unless youtube_video_id.present?
    "https://img.youtube.com/vi/#{youtube_video_id}/maxresdefault.jpg"
  end

  private

  def must_have_media
    unless has_media?
      errors.add(:base, "Une activité doit avoir au moins une vidéo YouTube ou des photos")
    end
  end

  def activity_date_not_after_today
    return if activity_date.blank?

    if activity_date > Date.current
      errors.add(:activity_date, "ne peut pas être postérieure à aujourd'hui")
    end
  end
end
