class StripeCustomerService
  def initialize(user)
    @user = user
  end

  def assign_customer_id
    return if @user.stripe_customer_id.present?

    begin
      customer = Stripe::Customer.create(name: @user.full_name, email: @user.email)
      @user.update(stripe_customer_id: customer.id)
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe API error: #{e.message}"
    end
  end
end
