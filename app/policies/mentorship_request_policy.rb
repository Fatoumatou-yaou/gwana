# frozen_string_literal: true

class MentorshipRequestPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present? && (record.requester == user || record.mentor == user || user.admin? || user.admin_reseau?)
  end

  def create?
    user.present? && user.member?
  end

  def update?
    user.present? && (record.mentor == user || user.admin? || user.admin_reseau?)
  end

  def destroy?
    user.present? && (record.requester == user || user.admin? || user.admin_reseau?)
  end

  def accept?
    user.present? && record.mentor == user
  end

  def reject?
    user.present? && record.mentor == user
  end

  class Scope < Scope
    def resolve
      if user&.admin? || user&.admin_reseau?
        scope.all
      elsif user&.mentor?
        scope.for_mentor(user.id)
      elsif user&.member?
        scope.for_requester(user.id)
      else
        scope.none
      end
    end
  end
end

