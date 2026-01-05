
class MentorshipRequestPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present? && (record.requester == user || record.mentor == user || user.admin?)
  end

  def new?
    create?
  end

  def create?
    user.present? && user.user?
  end

  def update?
    user.present? && (record.mentor == user || user.admin?)
  end

  def destroy?
    user.present? && (record.requester == user || user.admin?)
  end

  def accept?
    user.present? && record.mentor == user
  end

  def reject?
    user.present? && record.mentor == user
  end

  class Scope < Scope
    def resolve
      if user&.admin?
        scope.all
      elsif user&.gwana?
        scope.for_mentor(user.id)
      elsif user&.user?
        scope.for_requester(user.id)
      else
        scope.none
      end
    end
  end
end

