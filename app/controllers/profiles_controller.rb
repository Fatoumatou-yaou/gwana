# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_member, only: %i[show edit update]

  def show
    @member = current_user.member_profile || build_member
  end

  def edit
    @member = current_user.member_profile || build_member
  end

  def update
    @member = current_user.member_profile || current_user.build_member_profile

    if @member.update(member_params)
      redirect_to profile_path, notice: t("profiles.update.success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_member
    @member = current_user.member_profile
  end

  def build_member
    current_user.build_member_profile
  end

  def member_params
    params.require(:member).permit(
      :first_name, :last_name, :bio, :profession, :skills,
      :region, :available_for_mentorship, :linkedin_url,
      :twitter_url, :website_url, :photo
    )
  end
end
