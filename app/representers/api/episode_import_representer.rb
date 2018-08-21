# encoding: utf-8

class Api::EpisodeImportRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :guid
  property :audio
  property :entry
  property :status, writeable: false
  property :created_at, writeable: false
  property :updated_at, writeable: false

  def self_url(represented)
    api_authorization_podcast_import_episode_import_path(represented.podcast_import, represented)
  end

  def series_title(represented)
    return nil unless represented.podcast_import.series.present?

    represented.podcast_import.series.title
  end

  link :podcast_import do
    {
      href: api_authorization_podcast_import_path(represented.podcast_import),
      title: series_title(represented)
    } if represented.podcast_import_id
  end
  embed :series, class: Series, decorator: Api::Min::SeriesRepresenter, zoom: false

  link :story do
    {
      href: api_story_path(represented.story),
      title: represented.story.title,
      profile: model_uri(represented.story)
    } if represented.story
  end
  embed :story, as: :story, item_class: Story, decorator: Api::Min::StoryRepresenter, zoom: false
end
