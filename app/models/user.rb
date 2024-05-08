class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  default_scope { order created_at: :desc }

  validates :full_name, presence: true, length: {maximum: 35}

  has_many :bookings

  after_save :assign_stripe_customer_id

  def assign_stripe_customer_id
    return if stripe_customer_id.present?
    StripeCustomerService.new(self).assign_customer_id
  end
end
