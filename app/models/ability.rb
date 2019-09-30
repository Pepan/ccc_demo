# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.guest

    if user.role_names.include? :quest
      no_admin_access_actions
    end

    if user.role_names.include? :user
      no_admin_access_actions
      can [:read, :edit, :update, :trophy_case], User, id: user.id
      can :read, :something
    end

    if user.role_names.include? :admin
      can :access, :admin
      can :manage, :all
      cannot :destroy, :all
    end

    if user.role_names.include? :super_admin
      can :access, :admin
      can :manage, :all
    end

    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end

  private

  def no_admin_access_actions
    cannot :access, :admin
  end
end
