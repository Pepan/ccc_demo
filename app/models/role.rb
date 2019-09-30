# frozen_string_literal: true

class Role < ApplicationRecord
  has_and_belongs_to_many :users, join_table: :users_roles

  belongs_to :resource,
             polymorphic: true,
             optional: true

  validates :resource_type,
            inclusion: { in: Rolify.resource_types },
            allow_nil: true

  scopify

  def to_s
    I18n.t("app.#{self.class.name.underscore}.#{name}", raise: !Rails.env.production?)
  end

  def description
    to_s
  end
end
