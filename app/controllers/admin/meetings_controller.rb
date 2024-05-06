module Admin
  class MeetingsController < Admin::ApplicationController
    def default_sorting_attribute
      :start_time
    end
    
    def default_sorting_direction
      :desc
    end
  end
end
