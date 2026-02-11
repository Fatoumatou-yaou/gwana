class NetworkEvent < ApplicationRecord
  include Draper::Decoratable

  has_many_attached :photos

  # Validations
  validates :name, presence: true, length: { minimum: 3, maximum: 200 }
  validates :description, presence: true, length: { minimum: 10, maximum: 5000 }
  validates :event_date, presence: true
  validate :photos_count_limit
  validate :photos_size_limit
  validate :photos_format

  # Scopes
  scope :recent, -> { order(event_date: :desc, created_at: :desc) }
  scope :upcoming, -> { where("event_date >= ?", Date.current) }
  scope :past, -> { where("event_date < ?", Date.current) }

  # Instance methods
  def has_photos?
    photos.attached?
  end

  def photos_count
    photos.count
  end

  private

  def photos_count_limit
    return unless photos.attached?

    # Compter toutes les photos attachées (existantes + nouvelles lors d'un update)
    total_count = photos.count
    
    if total_count > 30
      errors.add(:photos, "ne peut pas dépasser 30 photos (actuellement : #{total_count})")
    end
  end

  def photos_size_limit
    return unless photos.attached?

    photos.each do |photo|
      next unless photo.respond_to?(:byte_size)
      
      if photo.byte_size > 2.megabytes
        size_in_mb = (photo.byte_size / 1.megabyte.to_f).round(2)
        filename = photo.respond_to?(:filename) ? photo.filename.to_s : "photo"
        errors.add(:photos, "contient une photo (#{filename}) qui dépasse 2 Mo (taille actuelle : #{size_in_mb} Mo)")
      end
    end
  end

  def photos_format
    return unless photos.attached?

    allowed_types = %w[image/jpeg image/jpg image/png image/webp]
    
    photos.each do |photo|
      next unless photo.respond_to?(:content_type)
      
      unless photo.content_type.in?(allowed_types)
        filename = photo.respond_to?(:filename) ? photo.filename.to_s : "fichier"
        errors.add(:photos, "contient un fichier (#{filename}) au format non autorisé. Formats acceptés : JPEG, PNG, WebP")
      end
    end
  end
end

