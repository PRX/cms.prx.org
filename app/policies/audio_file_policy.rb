class AudioFilePolicy < AccountablePolicy
  def original?
    update?
  end
end
