# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[edit update destroy confirm]

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    authorize! :update, @user
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      # must be deliver now for keeping 'confirm_token' set
      ConfirmationMailer.confirm(user_params[:email], @user).deliver_now
      redirect_to root_path, success: t("app.#{controller_name}.created")
    else
      render :new
    end
  end

  # PATCH/PUT /users/1
  def update
    authorize! :update, @user
    if @user.update(user_params)
      redirect_to [:edit, @user], success: t("app.#{controller_name}.updated")
    else
      render :edit
    end
  end

  # DELETE /users/1
  def destroy
    authorize! :destroy, @user
    log_out if @user == current_user
    @user.destroy
    redirect_to root_path, warning: t("app.#{controller_name}.destroyed")
  end

  # PATCH/PUT /users/confirm/1
  def confirm
    options = if @user.confirm(user_confirm_params)
                { success: t("app.#{controller_name}.confirmed") }
              else
                { error: @user.errors.full_messages.first }
              end
    redirect_to root_path, options
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:login, :email, :password, :password_confirmation)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_confirm_params
    params.require(:token)
  end
end
