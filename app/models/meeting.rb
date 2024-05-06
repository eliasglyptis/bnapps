class Meeting < ApplicationRecord
  has_many :bookings

  validates :topic, presence: true, length: { maximum: 50 }
  validates :image, :start_time, :duration, presence: true
end
