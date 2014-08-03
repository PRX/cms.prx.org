# encoding: utf-8

class MusicalWork < BaseModel

  belongs_to :story, class_name: 'Story', foreign_key: 'piece_id', with_deleted: true 

  acts_as_list scope: :piece_id

end
