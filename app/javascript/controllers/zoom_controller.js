import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="zoom"
export default class extends Controller {
  // List of values for stimulus controller
  static values = {
    meetingNumber: Number,
    meetingPassword: String,
    userName: String,
    csrfToken: String,
  };

  connect() {
    this.fetchMeetingSignature()
  }

  async fetchMeetingSignature() {
    try {
      const response = await fetch('/generate_signature', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-CSRF-Token': this.csrfTokenValue,
        },
        body: JSON.stringify({
          meetingNumber: this.meetingNumberValue,
        }),
      });
  
      if (!response.ok) {
        // If the response is not okay, throw an error
        throw new Error(`Failed to fetch meeting signature. HTTP status: ${response.status}`);
      }
  
      const data = await response.json();
      console.log('Meeting signature data:', data);
  
      // Handle the data received (e.g., passing the signature to another function)
      // Add your logic here
  
    } catch (error) {
      console.error('Error fetching meeting signature:', error);
      // Handle the error (e.g., show an error message to the user)
    }
  }
  
}
