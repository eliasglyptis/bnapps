class PaysController < ApplicationController
  before_action :authenticate_user!
  before_action :set_meeting

  def purchase
     # check if user already joined this booking
  end 

  def join_free
    # Check if user already joined this booking
    if Booking.exists?(user_id: current_user.id, meeting_id: @meeting.id)
      flash[:alert] = "You already joined this meeting."
    else
      # Use transaction block for better data consistency
      Booking.transaction do
        # Create new booking
        Booking.create!(
          user_id: current_user.id,
          meeting_id: @meeting.id,
          price: @meeting.price
        )
        flash[:notice] = "Awesome, you have joined the meeting successfully."
      end
    end
    redirect_to dashboard_path
  end

  private
  def set_meeting
    @meeting = Meeting.find(params[:meeting_id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Meeting not found."
    redirect_to dashboard_path
  end

end