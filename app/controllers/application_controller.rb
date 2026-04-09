class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  helper_method :current_mode

  layout :layout_by_resource

  private

  def current_mode
    params[:mode] || "amount"
  end

  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end
end
