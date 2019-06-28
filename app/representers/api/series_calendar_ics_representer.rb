require 'representable/object'

class Api::SeriesCalendarICSRepresenter < Representable::Decorator
  include ::Representable::Object

  def calendar
    cal = Icalendar::Calendar.new

    represented.
      stories.
      public_calendar_stories.
      order('pieces_published_released_at ASC').
      pluck('pieces.title, COALESCE(published_at, released_at) AS pieces_published_released_at').
      each do |story_frag|
      story_title, published_released_at = story_frag

      event = Icalendar::Event.new
      event.dtstart = published_released_at
      event.summary = "#{represented.title}: #{story_title}"
      cal.add_event(event)
    end

    cal
  end

  def to_object
    calendar.to_ical
  end
end
