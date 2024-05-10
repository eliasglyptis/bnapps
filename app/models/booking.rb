class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :meeting

  # Define constants for date and time format and time zone
  TIME_ZONE = 'Eastern Time (US & Canada)'.freeze
  DATE_TIME_FORMAT = '%Y-%m-%dT%H:%M:%S'.freeze
  USER_FRIENDLY_DATE_FORMAT = '%B %d, %Y at %I:%M %p'.freeze

  def show_purchased_at
    # Convert the created_at time to the user's time zone and format it
    self.created_at.in_time_zone(TIME_ZONE).strftime(USER_FRIENDLY_DATE_FORMAT) + ' (EDT)'
  end

  # Callback to send confirmation email after booking creation
  after_create :send_confirm_email

  private

  def send_confirm_email
    begin
      # Use deliver_later to send email asynchronously
      PayMailer.confirm(self).deliver_later
      Rails.logger.info "Confirmation email sent to #{self.user.email} for booking #{self.id}"
    rescue StandardError => e
      # Log an error if email sending fails
      Rails.logger.error "Failed to send confirmation email for booking #{self.id}: #{e.message}"
    end
  end
  
  # belongs_to :user
  # belongs_to :meeting

  # def show_purchased_at
  #   "#{self.created_at.to_datetime.strftime('%Y-%m-%dT%H:%M:%S')} (EDT)"
  # end

  # after_create :send_confirm_email

  # private

  # def send_confirm_email
  #   PayMailer.confirm(self).deliver_now
  # end
end
