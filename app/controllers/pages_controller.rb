class PagesController < ApplicationController
  def home
    @meetings = Meeting.upcoming
  end

  def about
  end

  def contact
  end

  def dashboard
  end

  def thank_you
  end
end
