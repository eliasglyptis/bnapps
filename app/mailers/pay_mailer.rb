class PayMailer < ApplicationMailer
  
  def confirm(booking)
    @booking = booking
    mail(
      to: booking.user.email,
      from: "BN Apps <ocean1890@protonmail.com>",
      subject: "We are happy to have you in our '#{booking.meeting.topic}' meeting"
    )
  end

end

