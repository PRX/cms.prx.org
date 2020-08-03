class AudioFilePolicy < AccountablePolicy
  def original?
    token&.authorized?(resource.account.id, :read_private)
  end
end
