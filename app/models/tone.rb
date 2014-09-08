class Tone < BaseModel

  TONE_NAMES = ['Amusing','Authoritative','Contemplative','Dark','Delicate','Disturbing','Earnest','Edgy','Elaborate','Emotional','Engaging','Esoteric','Experimental','Fresh Air-ish','Humorous','Informational','Inspiring','Intimate','Intriguing','Light','Lighthearted','Melancholic','NPR NewsMagazine-y','Offbeat','Opinionated','Personal','Polished','Political','Provocative','Quirky','Raw','Real','Rough','Sad','Sentimental','Simple','Sound-Rich','Surprising','Suspenseful','Sweet','This American Life-esque','Thorough','Thoughtful','Unconventional','Unusual','Upbeat']

  belongs_to :story, class_name: 'Story', foreign_key: 'piece_id'

  validates_inclusion_of :name, :in => TONE_NAMES
  validates_uniqueness_of :name, scope: :story

  def to_tag
    name
  end

end
