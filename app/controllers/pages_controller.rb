class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:dashboard, :receipt, :zoom, :thank_you]

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

  def zoom
    is_joined = current_user.bookings.exists?(meeting_id: params[:meeting_id])
    redirect_to dashboard_path, alert: "You don't have persmission for this action" if !is_joined

    @meeting = Meeting.find(params[:meeting_id])
  end

end
