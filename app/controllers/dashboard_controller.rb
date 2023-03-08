class DashboardController < ApplicationController
  def index
    @logs = Log.order(:requested_at, :desc).last(10)
  end
end
