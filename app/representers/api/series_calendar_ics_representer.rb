require 'representable/object'

class Api::SeriesCalendarICSRepresenter < Representable::Decorator
  include ::Representable::Object

  def to_object
    represented.calendar.to_ical
  end
end
