require 'jwt'

class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:dashboard, :receipt, :generate_signature, :zoom, :thank_you]

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

  def generate_signature
    # Fetching the meeting number from params
    mn = params[:meetingNumber]
    
    # Validate meeting number
    if mn.nil? || mn.to_s.strip.empty?
      render json: { error: 'Invalid meeting number' }, status: 400 and return
    end
    
    # Set the role for the meeting (you might want to pass this as a parameter)
    role = params[:role] || 0 # Default role
    
    # Get current time in seconds (Epoch time)
    iat = Time.now.to_i - 30
    
    # Set the expiration time (2 hours from issuance time)
    exp = iat + (60 * 60 * 2)
    
    # JWT token header
    header = {
      alg: 'HS256',
      typ: 'JWT'
    }
    
    # JWT token payload
    payload = {
      sdkKey: Rails.application.credentials[Rails.env.to_sym][:zoom_sdk_client_id],
      mn: mn,
      role: role,
      iat: iat,
      exp: exp,
      appKey: Rails.application.credentials[Rails.env.to_sym][:zoom_sdk_client_id],
      tokenExp: exp
    }
    
    # Encode the token using JWT
    signature = JWT.encode(payload, Rails.application.credentials[Rails.env.to_sym][:zoom_sdk_client_secret], 'HS256', header)
    
    # Return the signature as a JSON response
    render json: { signature: signature }, status: 200
  end
  

  # def generate_signature
  #   # Meeting number
  #   mn = params[:meetingNumber]

  #   # Get current time in seconds
  #   iat = Time.now.to_i - 30
    
  #   # Expire variable to expire in 2 days
  #   exp = iat + 60 * 2

  #   # Header for the JWT token
  #   header = {
  #     alg: 'HS256',
  #     typ: 'JWT'
  #   }
  #   # Payload for the JWT token
  #   payload = {
  #     sdkKey: Rails.application.credentials[Rails.env.to_sym][:zoom_sdk_client_id],
  #     mn: mn,
  #     role: role,
  #     iat: iat,
  #     exp: exp,
  #     appKey: Rails.application.credentials[Rails.env.to_sym][:zoom_sdk_client_id],
  #     tokenExp: exp
  #   }

  #   # Encode the JWT token using the header, payload, and secret key
  #   signature = JWT.encode(payload, Rails.application.credentials[Rails.env.to_sym][:zoom_sdk_client_secret], 'HS256', header)

  #   # Return
  #   render json: {signature: signature}, status: 200

  # end

end
