class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:dashboard, :receipt]

  def home
    @meetings = Meeting.upcoming
  end

  def dashboard
    @my_upcoming_meetings = Meeting.upcoming
                                  .joins(:bookings)
                                  .where("bookings.user_id = ?", current_user.id)

    @my_bookings = current_user.bookings
  end

  def receipt
    @booking = current_user.bookings.where(id: params[:booking_id]).first

    if !@booking.nil?
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: "booking_#{@booking.id}", template: "pages/receipt", formats: [:html], disposition: "attachment" # Excluding ".pdf" extension.
        end
      end
    else
      redirect_to dashboard_path
    end
  end

  def thank_you
  end
end
