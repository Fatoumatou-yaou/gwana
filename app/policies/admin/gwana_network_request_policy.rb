class Admin::GwanaNetworkRequestPolicy < ApplicationPolicy
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
      user&.admin? ? scope.all : scope.none
    end
  end
end

