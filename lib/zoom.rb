require "http"
require "base64"

module Zoom
  class MeetingService

    ACCOUNT_ID = Rails.application.credentials[Rails.env.to_sym][:ACCOUNT_ID]
    CLIENT_ID = Rails.application.credentials[Rails.env.to_sym][:CLIENT_ID]
    CLIENT_SECRET = Rails.application.credentials[Rails.env.to_sym][:CLIENT_SECRET]
    USER_ID = Rails.application.credentials[Rails.env.to_sym][:USER_ID]

    def create_meeting(payload)
      access_token = get_access_token
      return unless access_token # Ensure access token is valid

      response = HTTP.post(
        "https://api.zoom.us/v2/users/#{USER_ID}/meetings",
        headers: {
          "Authorization" => access_token
        },
        json: payload
      )

      handle_response(response)
    end

    def update_meeting(meeting_id, payload)
      access_token = get_access_token
      return unless access_token # Ensure access token is valid

      response = HTTP.patch(
        "https://api.zoom.us/v2/meetings/#{meeting_id}",
        headers: {
          "Authorization" => access_token
        },
        json: payload
      )

      handle_response(response)
    end

    private
    def get_access_token
      auth = "Basic " + Base64.encode64("#{CLIENT_ID}:#{CLIENT_SECRET}").delete("\n")

      response = HTTP.post(
        "https://zoom.us/oauth/token",
        headers: { "Authorization" => auth },
        params: {
          grant_type: "account_credentials",
          account_id: ACCOUNT_ID
        }
      )

      if response.status.success?
        data = response.parse
        return "Bearer " + data["access_token"]
      else
        Rails.logger.error("Failed to obtain access token: #{response.status} - #{response.body}")
        return nil
      end
    end

    def handle_response(response)
      if response.status.success?
        response.parse # Parse the response body
      else
        Rails.logger.error("API request failed: #{response.status} - #{response.body}")
      end
    end

  end
end
