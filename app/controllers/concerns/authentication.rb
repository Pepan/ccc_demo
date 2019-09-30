# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!

    attr_reader :current_user
    helper_method :current_user

    attr_reader :present_user
    helper_method :present_user
  end

  protected

  def prepare_present_user
    @present_user = @current_user || User.guest
  end

  # @param [User] user
  def log_in(user)
    session[:user_id] = user.id
  end

  def resolve_situation_of(user, session_params)
    return t("app.#{controller_name}.create.missing") unless user
    user.errors.full_messages.first unless user.authenticate(session_params[:password])
  end

  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
    prepare_present_user
  end

  # Remembers a user in a persistent session.
  # @param [User] user
  def remember(user)
    user.remember!
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Forgets a persistent session.
  def forget(user)
    user.forget!
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  private

  def authenticate_user!
    user = User.find_by(id: session[:user_id] || cookies.signed[:user_id])
    if user
      authorized?(user) and (@current_user = user)
    else
      flash.now[:error] = t('app.user.missing_on_auth') if session[:user_id]
    end
  end

  # @param [User] user
  def authorized?(user)
    flash.now[:error] = t('app.user.unauthenticated') unless user.authenticated?(cookies[:remember_token])
    flash.now[:error] = t('app.user.unconfirmed') if !user.guest? && user.confirmed_at.nil?
    user.authenticated?(cookies[:remember_token]) && (user.guest? || !user.confirmed_at.nil?)
  end
end
