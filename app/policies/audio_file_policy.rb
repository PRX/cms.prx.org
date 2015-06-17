class AudioFilePolicy < AccountablePolicy
  def original?
    token && token.authorized?(resource.account.id, 'read-private')
  end
end
