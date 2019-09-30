class User < ApplicationRecord
  include AuthSession

  rolify

  attr_accessor :seeding

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  before_validation :prepare_default_values, on: :create
  validates :nick, presence: true, uniqueness: true

  accepts_nested_attributes_for :roles, reject_if: :all_blank

  def admin?
    @admin ||= has_any_role?(:admin, :super_admin)
  end

  def guest?
    @guest ||= has_role?(:guest)
  end

  def to_s
    nick
  end

  def description
    "#{to_s}"
  end

  alias name to_s
  alias full_name to_s

  def role_names
    @role_names ||= roles.pluck(:name).map &:to_sym
  end

  private

  def prepare_default_values
    self.nick ||= email.split(/(\.|@)/).map { |value| value.gsub(/\B..*(?!$)/, '*') }.join.tr('@', '*') + rand(1..99).to_s if email
  end
end
