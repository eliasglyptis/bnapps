module Admin
  class BookingsController < Admin::ApplicationController
    def default_sorting_attribute
      :created_at
    end
    
    def default_sorting_direction
      :desc
    end
  end
end
