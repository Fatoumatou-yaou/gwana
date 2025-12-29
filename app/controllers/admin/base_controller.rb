class Admin::BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin

    private

    def authorize_admin
    redirect_to root_path, alert: "Vous n'êtes pas autorisé à effectuer cette action." unless current_user&.admin?
    end
end


