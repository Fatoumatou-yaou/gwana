class Api::LocationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def departments
    region_id = params[:region_id]
    
    if region_id.blank?
      render json: { error: "region_id parameter is required" }, status: :bad_request
      return
    end

    departments = Department.by_region(region_id).ordered
    render json: departments.map { |d| { id: d.id, name: d.name } }
  end

  def communes
    department_id = params[:department_id]
    
    if department_id.blank?
      render json: { error: "department_id parameter is required" }, status: :bad_request
      return
    end

    communes = Commune.by_department(department_id).ordered
    render json: communes.map { |c| { id: c.id, name: c.name } }
  end
end

