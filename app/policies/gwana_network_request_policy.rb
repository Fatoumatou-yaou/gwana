class GwanaNetworkRequestPolicy < ApplicationPolicy
  def show?
    true && !admin? || gwana?
  end

  def create?
    true && !admin? || gwana?
  end

  def new?
    true && !admin? || gwana?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end

