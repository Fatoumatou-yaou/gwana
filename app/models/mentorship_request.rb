
class MentorshipRequest < ApplicationRecord
  # Enums
  enum :status, {
    pending: 0,
    accepted: 1,
    rejected: 2,
    completed: 3,
    cancelled: 4
  }

  # Associations
  belongs_to :requester, class_name: "User"
  belongs_to :mentor, class_name: "User"
  belongs_to :commune, optional: true

  # Validations
  validates :message, presence: true, length: { minimum: 10 }
  validates :objectives, presence: true
  validates :motivation, presence: true, length: { minimum: 50 }
  validates :niveau_etudes, presence: true
  validates :filiere, presence: true
  validates :requester_id, presence: true
  validates :mentor_id, presence: true
  validate :requester_cannot_be_mentor
  validate :mentor_must_be_gwana

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :for_mentor, ->(mentor_id) { where(mentor_id: mentor_id) }
  scope :for_requester, ->(requester_id) { where(requester_id: requester_id) }

  # Callbacks
  after_create :send_notification_email

  # Instance methods
  def accept!
    update(status: :accepted)
    send_acceptance_notification
  end

  def reject!
    update(status: :rejected)
    send_rejection_notification
  end

  private

  def requester_cannot_be_mentor
    return unless requester_id == mentor_id

    errors.add(:base, "Le demandeur ne peut pas être son propre mentor")
  end

  def mentor_must_be_gwana
    return unless mentor_id.present?
    return if mentor&.gwana?

    errors.add(:mentor_id, "La mentor doit être une gwana")
  end

  def send_notification_email
    MentorshipRequestMailer.new_request(self).deliver_later
  end

  def send_acceptance_notification
    MentorshipRequestMailer.request_accepted(self).deliver_later
  end

  def send_rejection_notification
    MentorshipRequestMailer.request_rejected(self).deliver_later
  end
end
