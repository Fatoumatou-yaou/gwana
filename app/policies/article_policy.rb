# frozen_string_literal: true

class ArticlePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.published? || user.present? && (record.author == user || user.admin? || user.admin_reseau?)
  end

  def create?
    user.present? && (user.admin? || user.admin_reseau?)
  end

  def update?
    user.present? && (record.author == user || user.admin? || user.admin_reseau?)
  end

  def destroy?
    user.present? && (user.admin? || user.admin_reseau?)
  end

  def publish?
    user.present? && (user.admin? || user.admin_reseau?)
  end

  class Scope < Scope
    def resolve
      if user&.admin? || user&.admin_reseau?
        scope.all
      else
        scope.published
      end
    end
  end
end

