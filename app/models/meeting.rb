class Meeting < ApplicationRecord
  include Zoom
  has_many :bookings

  validates :topic, presence: true, length: { maximum: 50 }
  validates :image, :start_time, :duration, presence: true

  after_create :create_zoom_meeting
  after_update :update_zoom_meeting

  def create_zoom_meeting
    # Prepare payload
    payload = {
      topic: self.topic,
      password: self.password,
      start_time: self.start_time.to_datetime.strftime("%Y-%m-%dT%H:%M:%S"),
      duration: self.duration,
      time_zone: "America/Montreal"
    }
  
    begin
      # Create a Zoom meeting using the payload
      zoom_meeting = Zoom::MeetingService.new.create_meeting(payload)
      # Print the response for debugging
      puts "zoom_meeting: #{zoom_meeting.inspect}"
  
      # Parse the response if it's a valid JSON string
      if zoom_meeting.is_a?(String)
        data = JSON.parse(zoom_meeting)
        # Save Zoom ID to the database if the response contains an ID
        self.zoom_id = data["id"].to_i
        save
      else
        Rails.logger.error("Unexpected response type from Zoom API: #{zoom_meeting.class}")
      end
    rescue StandardError => e
      Rails.logger.error("Failed to create Zoom meeting: #{e.message}")
      # Add backtrace logging for debugging
      Rails.logger.error(e.backtrace.join("\n"))
    end
  end
  

  def update_zoom_meeting
    # Prepare payload
    payload = {
      topic: self.topic,
      password: self.password,
      start_time: self.start_time.to_datetime.strftime("%Y-%m-%dT%H:%M:%S"),
      duration: self.duration,
    }

    begin
      # Call the update_meeting method in Zoom::MeetingService to update the meeting
      response = Zoom::MeetingService.new.update_meeting(self.zoom_id, payload)
      puts "Response from update_meeting: #{response.inspect}" # Debugging

      # Handle the response and log any errors
      unless response.success?
          Rails.logger.error("Failed to update meeting: #{response.body}")
      end
    rescue StandardError => e
        Rails.logger.error("Error updating Zoom meeting: #{e.message}")
    end
  end

end

