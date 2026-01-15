
class MentorshipRequestPolicy < ApplicationPolicy
  def index?
    user? && !admin? && !gwana?
  end

  def show?
    user? && !admin? && !gwana?
  end

  def new?
    create?
  end

  def create?
    user? && !admin? && !gwana?
  end

  def update?
    user? && !admin? && !gwana?
  end

  def destroy?
    !gwana?
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

