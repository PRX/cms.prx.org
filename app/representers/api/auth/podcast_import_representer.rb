# encoding: utf-8

class Api::Auth::PodcastImportRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :status, writeable: false
  property :url

  link rel: :account, writeable: true do
    {
      href: api_account_path(represented.account),
      title: represented.account.name,
      profile: model_uri(represented.account)
    } if represented.id && represented.account_id
  end
  embed :account, class: Account, decorator: Api::Min::AccountRepresenter

  link rel: :series, writeable: true do
    {
      href: api_series_path(represented.series),
      title: represented.series.title
    } if represented.series_id
  end
  embed :series, class: Series, decorator: Api::Min::SeriesRepresenter

  def self_url(r)
    api_authorization_account_podcast_import_path(r.account, r)
  end
end
