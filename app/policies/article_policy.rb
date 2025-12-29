
class ArticlePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.published? || user.present? && (record.author == user || user.admin?)
  end

  def create?
    user.present? && user.admin?
  end

  def update?
    user.present? && (record.author == user || user.admin?)
  end

  def destroy?
    user.present? && user.admin?
  end

  def publish?
    user.present? && user.admin?
  end

  class Scope < Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.published
      end
    end
  end
end

