class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :meeting

  def show_purchased_at
    "#{self.created_at.to_datetime.strftime('%Y-%m-%dT%H:%M:%S')} (EDT)"
  end
end
