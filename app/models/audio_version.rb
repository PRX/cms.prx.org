class AudioVersion < PRXModel

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

end
