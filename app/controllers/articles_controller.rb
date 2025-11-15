# frozen_string_literal: true

class ArticlesController < ApplicationController
  before_action :set_article, only: [:show]

  def index
    @articles = Article.published.recent
    @articles = @articles.search_by_text(params[:search]) if params[:search].present?
    @articles = @articles.by_category(params[:category]) if params[:category].present?
  end

  def show
    authorize @article
  end

  private

  def set_article
    @article = Article.friendly.find(params[:id])
  end
end
