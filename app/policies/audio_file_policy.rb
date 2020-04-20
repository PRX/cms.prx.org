class AudioFilePolicy < AccountablePolicy
  def original?
    token && token.authorized?(resource.account.id) #todo: read-private
  end
end
