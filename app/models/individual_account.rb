# encoding: utf-8

class IndividualAccount < Account

  def name
    opener.try(:name)
  end

  def path
    opener.try(:login)
  end

  def image
    opener.try(:image)
  end

  def address
    opener.try(:address)
  end

end
