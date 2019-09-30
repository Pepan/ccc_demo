class PageController < ApplicationController
  skip_before_action :check_admin_access, only: [:home, :something]

  def home
  end

  def something
    authorize! :read, :something
  end
end
