# Preview all emails at http://localhost:3000/rails/mailers/pay_mailer
class PayMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/pay_mailer/confirm
  def confirm
    PayMailer.confirm
  end

end
