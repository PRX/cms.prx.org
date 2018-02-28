# encoding: utf-8

class Api::PodcastImportRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :url
  property :config
  property :config_url, readable: false
  property :status, writeable: false
  property :created_at, writeable: false
  property :updated_at, writeable: false

  def self_url(represented)
    api_authorization_podcast_import_path(represented)
  end

  link rel: :user, writeable: true do
    if represented.user
      {
        href: api_user_path(represented.user),
        title: represented.user.login
      }
    end
  end

  link rel: :series, writeable: true do
    if represented.series_id
      {
        href: api_series_path(represented.series),
        title: represented.series.title
      }
    end
  end
  embed :series, class: Series, decorator: Api::Min::SeriesRepresenter

  link :episode_imports do
    if represented.id
      {
        href: "#{api_authorization_podcast_import_episode_imports_path(represented)}#{index_url_params}",
        templated: true,
        count: represented.episode_imports.count
      }
    end
  end
  embed :episode_imports,
        paged: true,
        item_class: EpisodeImport,
        item_decorator: Api::EpisodeImportRepresenter,
        zoom: true
end
