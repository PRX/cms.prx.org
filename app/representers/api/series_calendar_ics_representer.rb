require 'representable/object'

class Api::SeriesCalendarICSRepresenter < Representable::Decorator
  include ::Representable::Object

  def series
    represented
  end

  def calendar
    cal = Icalendar::Calendar.new

    series.
      stories.
      public_calendar_stories.
      each do |story_frag|
      published_released_at, season_identifier, episode_identifier = story_frag
      placeholder_title = PublicCalendarTitlePlaceholderBuilder.
                          new(published_released_at, season_identifier, episode_identifier).
                          generate!

      event = Icalendar::Event.new
      event.dtstart = published_released_at
      event.summary = "#{series.title}: #{placeholder_title}"
      cal.add_event(event)
    end

    cal
  end

  def to_object
    calendar.to_ical
  end
end
