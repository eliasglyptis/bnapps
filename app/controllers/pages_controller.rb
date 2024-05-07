class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:dashboard]

  def home
    @meetings = Meeting.upcoming
  end

  def dashboard
    @my_upcoming_meetings = Meeting.upcoming
                                  .joins(:bookings)
                                  .where("bookings.user_id = ?", current_user.id)
  end

  def thank_you
  end
end
