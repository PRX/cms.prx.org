# encoding: utf-8

class StoryImage < Image

  self.table_name = 'piece_images'

  belongs_to :story, -> { with_deleted }, class_name: 'Story', foreign_key: 'piece_id', touch: true

  acts_as_list scope: :piece_id

end
