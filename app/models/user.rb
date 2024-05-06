class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  default_scope { order created_at: :desc }

  validates :full_name, presence: true, length: {maximum: 35}

  has_many :bookings
end
