
class Admin::GwanaUpdateRequestPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin?
  end

  def approve?
    admin?
  end

  def reject?
    admin?
  end

  class Scope < Scope
    def resolve
      admin? ? scope.all : scope.none
    end
  end
end

