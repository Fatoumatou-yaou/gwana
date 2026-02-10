class GwanaPortraitVideo < ApplicationRecord
  include Draper::Decoratable

  belongs_to :gwana

  # Callbacks
  before_validation :set_default_display_order, on: :create

  # Validations
  validates :youtube_video_id, presence: true
  validates :teaser_text, presence: true, length: { minimum: 10, maximum: 200 }
  validates :display_order, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
  scope :ordered, -> { order(display_order: :asc, created_at: :desc) }
  scope :recent, -> { order(display_order: :asc, created_at: :desc) }

  # Instance methods
  def youtube_embed_url
    return nil unless youtube_video_id.present?
    "https://www.youtube.com/embed/#{youtube_video_id}?modestbranding=1&rel=0"
  end

  def youtube_thumbnail_url
    return nil unless youtube_video_id.present?
    "https://img.youtube.com/vi/#{youtube_video_id}/maxresdefault.jpg"
  end
  
  private
  def set_default_display_order
    return if display_order.present?
    
    max_order = gwana&.portrait_videos&.maximum(:display_order) || -1
    self.display_order = max_order + 1
  end
end
