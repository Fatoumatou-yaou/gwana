class Admin::GwanaPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def new?
    admin?
  end

  def edit?
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

  class Scope < Scope
    def resolve
      admin? ? scope.all : scope.none
    end
  end
end

