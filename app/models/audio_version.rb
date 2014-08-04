# encoding: utf-8

class AudioVersion < BaseModel

  BREAK_TYPES = {
    :news_hole_break? => 'News Hole',
    :floating_break? => 'Floating',
    :bottom_of_hour_break? => 'Bottom of the Hour',
    :twenty_forty_break? => '20 and 40 min'
  }

  belongs_to :story, class_name: 'Story', foreign_key: 'piece_id', with_deleted: true
  has_many :audio_files, -> { order :position }, dependent: :destroy

  acts_as_paranoid

  def length(reload=false)
    @_length = nil if reload
    @_length ||= self.audio_files.inject(0){|sum, f| sum + f.length}

    # @_length ||= if !new_record?
    #   len = AudioVersion.connection.select_one("SELECT SUM(length) as l
    #   FROM audio_files
    #   WHERE audio_version_id = #{self.id}
    #   AND   status != '#{AudioFile::INVALID_AUDIO}'
    #   AND   deleted_at is null")
    #   len['l'].to_i
    # else
    #   self.audio_files.inject(0){|sum, f| sum + f.length}
    # end
  end

  def as_default_audio
    @_default_audio ||= if promos?
      [audio_files.max_by(&:length)]
    else
      audio_files
    end
  end

  def default_audio_duration
    @_default_audio_duration ||= if promos?
      as_default_audio.first.length
    else
      length
    end
  end

  def breaks
    @_breaks ||= [].tap do |array|
      BREAK_TYPES.each do |method, text|
        array.push text if send method
      end
    end
  end

end
