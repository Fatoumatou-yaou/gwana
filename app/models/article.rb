
class Article < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  include PgSearch::Model

  # Associations
  belongs_to :author, class_name: "User"
  has_one_attached :photo
  has_one_attached :video

  # Enums
  enum :media_type, { no_media: "none", photo: "photo", video: "video" }, default: "none", prefix: :media

  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :slug, uniqueness: true, allow_nil: true
  validates :author_id, presence: true
  validates :category, presence: true
  validate :media_presence_if_media_type_set
  validate :video_format, if: -> { video.attached? }
  validate :photo_format, if: -> { photo.attached? }

  # Scopes
  scope :published, -> { where(published: true).where.not(published_at: nil) }
  scope :draft, -> { where(published: false) }
  scope :recent, -> { order(published_at: :desc) }
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :with_photo, -> { where(media_type: "photo") }
  scope :with_video, -> { where(media_type: "video") }

  # Full-text search
  pg_search_scope :search_by_text,
                  against: %i[title tags],
                  using: {
                    tsearch: { prefix: true }
                  }

  # Callbacks
  before_save :set_published_at, if: :published_changed?

  # Instance methods
  def tags_array
    return [] if tags.blank?

    tags.split(",").map(&:strip)
  end

  def should_generate_new_friendly_id?
    title_changed? || slug.blank?
  end

  # Instance methods
  def has_media?
    photo.attached? || video.attached?
  end

  def media_url
    return photo.url if photo.attached?
    return video.url if video.attached?
    nil
  end


  private

  def set_published_at
    self.published_at = Time.current if published? && published_at.nil?
  end

  def media_presence_if_media_type_set
    if media_type == "photo" && !photo.attached?
      errors.add(:photo, "doit être fournie pour une actualité avec photo")
    elsif media_type == "video" && !video.attached?
      errors.add(:video, "doit être fournie pour une actualité avec vidéo")
    end
  end

  def video_format
    return unless video.attached?

    unless video.content_type.in?(%w[video/mp4 video/webm video/ogg video/quicktime])
      errors.add(:video, "doit être au format MP4, WebM, OGG ou QuickTime")
    end

    if video.byte_size > 100.megabytes
      errors.add(:video, "ne doit pas dépasser 100 Mo")
    end
  end

  def photo_format
    return unless photo.attached?

    unless photo.content_type.in?(%w[image/jpeg image/jpg image/png image/webp])
      errors.add(:photo, "doit être au format JPEG ou WebP")
    end
  end
end
