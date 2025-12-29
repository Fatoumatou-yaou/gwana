class Department < ApplicationRecord
  # Associations
  belongs_to :region
  has_many :communes, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :name, uniqueness: { scope: :region_id }

  # Scopes
  scope :ordered, -> { order(:name) }
  scope :by_region, ->(region_id) { where(region_id: region_id) if region_id.present? }
end

