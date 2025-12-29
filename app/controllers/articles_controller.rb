
class ArticlesController < ApplicationController
  layout "slim"
  before_action :set_article, only: [:show]

  def index
    articles = Article.published.recent
    articles = articles.search_by_text(params[:search]) if params[:search].present?
    articles = articles.by_category(params[:category]) if params[:category].present?
    @articles = decorate(articles)
  end

  def show
    authorize @article
    @article = @article.decorate
  end

  private

  def set_article
    @article = Article.friendly.find(params[:id])
  end
end
