# encoding: utf-8

class Format < BaseModel
  FORMAT_NAMES = ['Actuality','Aircheck','Archival','Commentary','Daily Segment','Debut (not aired nationally)','Diary','Documentary','Enterprise/Investigative','Essay','Fiction','First-Person Essay','Fundraising for Air','Fundraising for Air: Music','Fundraising for Air: News','Fundraising Sample','Fundraising Sample: Music','Fundraising Sample: News','Hard Feature','Interstitial','Interview','Limited Series','News Analysis','News Reporting','Soft Feature','Special','Weekly Program','Youth-Produced']

  belongs_to :story, class_name: 'Story', foreign_key: 'piece_id'

  validates_inclusion_of :name, in: FORMAT_NAMES
  validates_uniqueness_of :name, scope: :story

  def to_tag
    if name.match(/\AFundraising/)
      'Fundraising'
    elsif name.match(/\ADebut/)
      'Debut'
    else
      name
    end
  end

  def self.policy_class
    StoryAttributePolicy
  end
end
