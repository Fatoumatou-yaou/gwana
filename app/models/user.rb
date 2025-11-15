# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  # Enums
  enum :role, {
    member: 0,
    mentor: 1,
    admin_reseau: 2,
    admin: 3
  }

  # Associations
  has_one :member_profile, class_name: "Member", dependent: :destroy
  has_many :mentorship_requests_as_requester, class_name: "MentorshipRequest", foreign_key: "requester_id", dependent: :destroy
  has_many :mentorship_requests_as_mentor, class_name: "MentorshipRequest", foreign_key: "mentor_id", dependent: :destroy
  has_many :articles, foreign_key: "author_id", dependent: :destroy

  # Validations
  validates :role, presence: true

  # Scopes
  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :mentors, -> { where(role: :mentor) }
  scope :members, -> { where(role: :member) }

  # Helper methods
  def admin?
    role == "admin"
  end

  def admin_reseau?
    role == "admin_reseau"
  end

  def mentor?
    role == "mentor"
  end

  def member?
    role == "member"
  end
end
