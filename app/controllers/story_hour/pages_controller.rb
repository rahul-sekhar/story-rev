class StoryHour::PagesController < StoryHour::ApplicationController
  def events
    @class = "events"
    @title = "Current Events"
  end

  def about
    @class = "about"
    @title = "About"
  end

  def old
    @class = "old"
    @title = "Past Events"
  end
end