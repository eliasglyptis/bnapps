class PaysController < ApplicationController
  before_action :authenticate_user!
  before_action :set_meeting, only: [:purchase, :join_free]
  

  def purchase
    # Check if user already joined this booking
    if Booking.exists?(user_id: current_user.id, meeting_id: @meeting.id)
      redirect_to dashboard_path, alert: "You already joined this meeting."
      return
    end

    # Create Stripe checkout session
    begin
      checkout_session = Stripe::Checkout::Session.create({
        customer: current_user.stripe_customer_id,
        client_reference_id: @meeting.id,
        mode: "payment",
        payment_method_types: ["card"],
        line_items: [
          {
            price_data: {
              product_data: {
                name: @meeting.topic,
                description: @meeting.description,
                images: [@meeting.image],
              },
              unit_amount: @meeting.price * 100,
              currency: "usd",
            },
            quantity: 1,
          }
        ],
        success_url: thank_you_url(meeting_id: @meeting.id),
        cancel_url: root_url,
      })
      redirect_to checkout_session.url, allow_other_host: true
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe API error: #{e.message}"
      flash[:alert] = "An error occurred during the checkout process. Please try again."
      redirect_to dashboard_path
    end
  end

  def join_free
    # Check if user already joined this booking
    if Booking.exists?(user_id: current_user.id, meeting_id: @meeting.id)
      flash[:alert] = "You already joined this meeting."
    else
      # Use transaction block for data consistency
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
