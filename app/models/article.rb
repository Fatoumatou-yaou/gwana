# frozen_string_literal: true

class Article < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  include PgSearch::Model
  include ActionText::Attachable

  # Associations
  belongs_to :author, class_name: "User"
  has_one_attached :featured_image
  has_rich_text :content

  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :slug, uniqueness: true, allow_nil: true
  validates :author_id, presence: true
  validates :category, presence: true

  # Scopes
  scope :published, -> { where(published: true).where.not(published_at: nil) }
  scope :draft, -> { where(published: false) }
  scope :recent, -> { order(published_at: :desc) }
  scope :by_category, ->(category) { where(category: category) if category.present? }

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

  private

  def set_published_at
    self.published_at = Time.current if published? && published_at.nil?
  end
end
