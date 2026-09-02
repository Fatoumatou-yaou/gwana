class Admin::MentorshipRequestPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin?
  end

  def create?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

  def reject?
    admin?
  end

  def accept?
    admin?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
