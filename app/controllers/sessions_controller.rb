# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :set_user, only: %i[destroy]
  skip_before_action :check_admin_access
  skip_load_and_authorize_resource

  def new; end

  def create
    user = User.find_by login_digest: User.searchable_digest_from(session_params[:email], User::LOGIN_DIGEST_ID)
    error = resolve_situation_of(user, session_params)

    if error
      flash.now[:error] = error
      render :new, status: :unprocessable_entity
    else
      log_in(user) && user.log_in!(request.remote_ip)
      session_params[:remember_me] == '1' ? remember(user) : forget(user)
      redirect_to root_path, success: t("app.#{controller_name}.created")
    end
  end

  def destroy
    options = if @user == current_user
                log_out
                { alert: t("app.#{controller_name}.destroyed") }
              else
                { error: t("app.#{controller_name}.bogus_destroy") }
              end
    redirect_to root_path, options
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def session_params
    params.require(:session).permit(:email, :password, :remember_me)
  end
end
