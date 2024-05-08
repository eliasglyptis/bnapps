class PaysController < ApplicationController
  before_action :authenticate_user!, except: [:webhook] # exception webhook because webhook is calling from outside the app.
  before_action :set_meeting, except: [:webhook] # exception webhook because webhook is calling from outside the app.
  

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

  protect_from_forgery except: :webhook
  def webhook
    endpoint_secret = Rails.application.credentials[Rails.env.to_sym][:stripe_endpoint_secret]
    event = nil

    begin
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      payload = request.body.read
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      # Invalid payload
      #return status 400
      render json: {message: e}, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      #return status 400
      render json: {message: e}, status: 400
      return
    end

    # Create new booking if payment success
    if event['type'] == 'checkout.session.completed'
      create_booking(event.data.object)
    end
    render json: {message: "Success"}, status: 200

  end

  private

  def set_meeting
    @meeting = Meeting.find(params[:meeting_id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Meeting not found."
    redirect_to dashboard_path
  end

  def create_booking(checkout_session)
    # 1. Retrieve the meeting using the client reference ID
    begin
      meeting = Meeting.find(checkout_session.client_reference_id)
    rescue ActiveRecord::RecordNotFound
      Rails.logger.error "Meeting not found for client reference ID: #{checkout_session.client_reference_id}"
      return
    end
  
    # 2. Retrieve the user using the Stripe customer ID
    user = User.find_by(stripe_customer_id: checkout_session.customer)
    unless user
      Rails.logger.error "User not found for Stripe customer ID: #{checkout_session.customer}"
      return
    end
  
    # 3. Check if a booking already exists for this user and meeting
    if Booking.exists?(user_id: user.id, meeting_id: meeting.id)
      Rails.logger.warn "Booking already exists for user #{user.id} and meeting #{meeting.id}"
      return
    end
  
    # 4. Create a new booking in the database
    begin
      Booking.transaction do
        booking = Booking.create!(
          user_id: user.id,
          meeting_id: meeting.id,
          price: meeting.price
        )
        Rails.logger.info "Booking created successfully: #{booking.inspect}"
      end
    rescue StandardError => e
      Rails.logger.error "Failed to create booking: #{e.message}"
    end
  end
  
end
