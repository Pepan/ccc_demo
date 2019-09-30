# frozen_string_literal: true

module AuthSession
  extend ActiveSupport::Concern

  EMAIL_REGEXP = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  PASSWORD_LENGTH = 8
  LOGIN_DIGEST_ID = 38
  USER_TOKEN_DIGEST_ID = 82
  USER_PERSONAL_DIGEST_ID = 163

  class_methods do
    S_DIGEST_SALT = '84GEH-H46E8.Whr'

    def searchable_digest_from(value, id)
      Digest::SHA1.hexdigest "#{S_DIGEST_SALT} #{value} #{id}"
    end

    def password_digest_from(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    def random_token
      SecureRandom.urlsafe_base64
    end

    def guest
      @guest ||= with_role(:guest).first
    end
  end

  included do
    has_secure_password

    attr_accessor :email
    attr_accessor :remember_token, :confirm_token

    before_validation :prepare_values

    validates :email, presence: true, format: { with: EMAIL_REGEXP }, on: :create
    validates :password, presence: true, length: { minimum: PASSWORD_LENGTH }, on: :create

    validates :login_digest, :password_digest, presence: true
    validates :login_digest, uniqueness: true

    after_create :assign_default_role, :create_confirm_token
    before_save :reset_authentication_token, if: ->{password_digest_changed?}

    def authenticate(unencrypted_password)
      if !super # check that auth was ok before providing user specific information
        errors.add :base, I18n.t('app.user.wrong_password')
      elsif confirmed_at.nil?
        errors.add :base, I18n.t('app.user.unconfirmed')
      end
      errors.empty?
    end
  end

  def reset_authentication_token!
    update_columns authentication_token: generate_authentication_token
  end

  def reset_authentication_token
    assign_attributes authentication_token: generate_authentication_token
  end

  def reset_password!
    new_password = SecureRandom.hex(PASSWORD_LENGTH / 2) # 2 chars for each num
    update_attributes!(password: new_password, password_confirmation: new_password)
    new_password
  end

  def confirm(token)
    if confirmation_sent_at.nil?
      errors.add :confirmation_sent_at, I18n.t('app.user.confirm_not_required')
      false
    elsif !confirmed_at.nil?
      errors.add :confirmed_at, I18n.t('app.user.already_confirmed')
      false
    elsif token != User.searchable_digest_from(id, User::USER_TOKEN_DIGEST_ID)
      errors.add :confirmed_at, I18n.t('app.user.wrong_confirm_token')
      false
    else
      update_columns confirmed_at: DateTime.current
      token == User.searchable_digest_from(id, User::USER_TOKEN_DIGEST_ID)
    end
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember!
    self.remember_token = User.random_token
    update_attribute(:remember_digest, User.password_digest_from(remember_token))
  end

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
    return true if remember_digest.nil?
    return false if remember_token.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Forgets a user.
  def forget!
    update_attribute(:remember_digest, nil)
  end

  def log_in!(remote_ip)
    increment :sign_in_count
    self.sign_in_at = DateTime.current
    self.sign_in_ip = remote_ip
    save!
  end

  def create_confirm_token
    self.confirm_token = User.searchable_digest_from(id, User::USER_TOKEN_DIGEST_ID)
  end

  protected

  def personal_digest
    User.searchable_digest_from(id, User::USER_PERSONAL_DIGEST_ID)
  end

  private

  def assign_default_role
    add_role(:user) if roles.blank?
  end

  def prepare_values
    return if email.blank?
    new_digest = User.searchable_digest_from(email, User::LOGIN_DIGEST_ID)
    self.login_digest = new_digest if login_digest != new_digest
  end

  def generate_authentication_token
    loop do
      token = SecureRandom.base64.tr('+/=', 'Qrt')
      break token unless User.exists?(authentication_token: token)
    end
  end

  def token_params
    { user_id: id,
      authentication_token: authentication_token }
  end
end
