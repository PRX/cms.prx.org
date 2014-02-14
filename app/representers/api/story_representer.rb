class Api::StoryRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :id

# * Title
  property :title

# * Length
  property :length

# * Short Description
  property :short_description

# * Full Description
  property :description

# * Date added to PRX
  property :published_at

# * Date produced
  property :produced_on

# * Points
  property :points

# * Related Websites
  property :related_website

# * Broadcast history
  property :broadcast_history

# * Timing & Cues
  property :timing_and_cues, decorator_scope: true

  def timing_and_cues
    represented.default_audio_version.timing_and_cues
  end

# * Audio Files
  collection :default_audio, as: :audio, embedded: true, class: AudioFile, decorator: Api::AudioFileRepresenter


  link :self do 
    api_story_path(represented)
  end

end

# * Producer Name (producing account?)
# * Producing Account
#   * Name
#   * Username
#   * Location
#   * Photo
#   * Social Media Links
# * Producing Account's other Pieces (Doesn't make sense for right now)
# * List of Producers

# * Licensing terms
# * Musical Works
# * tags
# * image(s)

# require castle integration
# * Purchase Count
# * Listen Count (don't know if this makes sense to have here)

# requires search/solr integration
# * Related Pieces (obviously low priority)

# requires fb integration
# * Like Count (don't think this exists)

# doesn't exist
# * Accomplishments (Don't think this exists)
