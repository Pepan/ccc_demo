class ApplicationController < ActionController::Base
  include Authentication
  protect_from_forgery with: :exception

  add_flash_types :success, :error # default are :notice and :alert

  before_action :set_initials
  before_action :check_admin_access

  load_and_authorize_resource only: %i[show edit update destroy]

  rescue_from CanCan::AccessDenied do |exception|
    case
      when request.xhr?
        raise exception.message
      when params[:format] == 'json'
        render json: { alert: exception.message }, status: :unauthorized
      else
        redirect_to root_url, :alert => exception.message
    end
  end

  private

  def check_admin_access
    return redirect_to new_session_path unless current_user
    authorize! :access, :admin
  end

  def set_initials
    prepare_present_user

    # I18n.locale = present_user.profile.language || I18n.default_locale
    # I18n.locale = I18n.default_locale
  end
end
