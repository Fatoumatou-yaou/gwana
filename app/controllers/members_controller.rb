# frozen_string_literal: true

class MembersController < ApplicationController
  before_action :set_member, only: [:show]

  def index
    @members = Member.all
    @members = @members.search_by_text(params[:search]) if params[:search].present?
    @members = @members.by_region(params[:region]) if params[:region].present?
    @members = @members.by_profession(params[:profession]) if params[:profession].present?
    @members = @members.available_for_mentorship if params[:available] == "true"
    @members = @members.order(:first_name, :last_name)
  end

  def show
    authorize @member
  end

  private

  def set_member
    @member = Member.friendly.find(params[:id])
  end
end
