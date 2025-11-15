# frozen_string_literal: true

class MemberPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.present?
  end

  def update?
    user.present? && (record.user == user || user.admin? || user.admin_reseau?)
  end

  def destroy?
    user.present? && (user.admin? || user.admin_reseau?)
  end

  class Scope < Scope
    def resolve
      if user&.admin? || user&.admin_reseau?
        scope.all
      else
        scope.all
      end
    end
  end
end

