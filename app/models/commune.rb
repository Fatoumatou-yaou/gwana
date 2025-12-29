class Commune < ApplicationRecord
  # Associations
  belongs_to :department
  has_one :region, through: :department
  has_many :members, dependent: :nullify

  # Validations
  validates :name, presence: true
  validates :name, uniqueness: { scope: :department_id }

  # Scopes
  scope :ordered, -> { order(:name) }
  scope :by_department, ->(department_id) { where(department_id: department_id) if department_id.present? }
  scope :by_region, ->(region_id) { joins(:department).where(departments: { region_id: region_id }) if region_id.present? }
end

