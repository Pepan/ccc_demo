# frozen_string_literal: true

class BaseType < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def method_missing(method_name, *args)
      super unless method_name.to_s.start_with? 'the_'
      begin
        Thread.current["#{name}_#{method_name}"] ||= find_by!(code: method_name.to_s[4..-1])
      rescue ActiveRecord::RecordNotFound
        super
      end
    end

    def with(codes)
      return none if codes.nil?
      where(code: codes + codes.map(&:downcase))
    end
  end

  def to_s
    I18n.t("app.#{self.class.name.underscore}.#{code}", raise: !Rails.env.production?)
  end

  def description
    to_s
  end

  validates :code, presence: true
  validates :code, uniqueness: true
end
