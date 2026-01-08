
class Users::ConfirmationsController < Devise::ConfirmationsController
  layout "auth"
  
  protected

  def after_confirmation_path_for(_resource_name, _resource)
    root_path
  end
end
