class PublicCalendarTitlePlaceholderBuilder
  attr_reader :season_identifier,
              :episode_number,
              :published_released_at,
              :generated_title

  def initialize(published_released_at, season_identifier = nil, episode_number = nil)
    @published_released_at = published_released_at
    @season_identifier = season_identifier
    @episode_number = episode_number
    @generated_title = nil
  end

  def generate!
    title_parts = []
    if season_identifier || episode_number
      title_parts.push("Season: #{season_identifier}") if season_identifier
      title_parts.push("Episode: #{episode_number}") if episode_number
    else
      title_parts.push("Publish Release At: #{published_released_at}") if published_released_at
    end

    @generated_title = title_parts.join(', ')
  end
end
