class Admin::MentorshipRequestPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end

