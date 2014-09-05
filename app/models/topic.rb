class Topic < BaseModel
  TOPIC_NAMES = [ 'African-American','Art','Asian','Business','Children','Drama','Education','Entertainment','Environment',
                  'Family','Food','Garden','Gay and Lesbian','Historical','Historical Anniversaries','Holidays','Humor',
                  'Instructional','International','Labor','Latino','Literature','Media','Music','Native','News','Politics',
                  'Public Affairs','Religious','Science','Senior','Sports','Technology','Travel','War','Women','Youth']

  NPR_TOPIC_MAPPING = {
    'Art'=>1047,
    'Business'=>1006,
    'Drama'=>1046,
    'Education'=>1013,
    'Entertainment'=>1008,
    'Environment'=>1025,
    'Food'=>1053,
    'Garden'=>1054,
    'Historical'=>1136,
    'Historical Anniversaries'=>1136,
    'Humor'=>1052,
    'International'=>1004,
    'Literature'=>1008,
    'Media'=>1020,
    'Music'=>1106,
    'News'=>1001,
    'Politics'=>1014,
    'Public Affairs'=>1014,
    'Religious'=>1016,
    'Science'=>1007,
    'Senior'=>1028,
    'Sports'=>1055,
    'Technology'=>1019
  }

  belongs_to :story, class_name: 'Story', foreign_key: 'piece_id'
  validates_inclusion_of :name, in: TOPIC_NAMES

  def npr_topic_id
    NPR_TOPIC_MAPPING[name]
  end
end
