class Region < ApplicationRecord
  # Associations
  has_many :departments, dependent: :destroy
  has_many :communes, through: :departments

  # Validations
  validates :name, presence: true, uniqueness: true

  # Scopes
  scope :ordered, -> { order(:name) }
end

