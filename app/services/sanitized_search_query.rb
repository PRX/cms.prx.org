class SanitizedSearchQuery
  attr_reader :query

  SPECIAL_CHARS = Regexp.escape('\\/+-&|!(){}[]^~?:')

  def initialize(str)
    @query = sanitize(str) if str.present?
  end

  def present?
    query.present?
  end

  def to_s
    query
  end

  private

  def sanitize(str)
    str = str.strip
    str = escape_special_characters(str)
    str = remove_trailing_operators(str)
    str = remove_consecutive_operators(str)
    str = escape_odd_quotes(str)
    str
  end

  def escape_special_characters(str)
    str.gsub(/([#{SPECIAL_CHARS}])/, '\\\\\1')
  end

  def remove_trailing_operators(str)
    str.gsub(/(\s*(AND|OR|NOT))+\s*$/, '')
  end

  def remove_consecutive_operators(str)
    str.gsub(/(AND|OR|NOT)(\s+(AND|OR|NOT))+/, '\1')
  end

  # def escape_logical_operators(str)
  #   ['AND', 'OR', 'NOT'].each do |word|
  #     escaped_word = word.split('').map {|char| "\\#{char}" }.join('')
  #     str = str.gsub(/\s*\b(#{word.upcase})\b\s*/, " #{escaped_word} ")
  #   end
  # end

  def escape_odd_quotes(str)
    if str.count('"') % 2 == 1
      str.gsub(/(.*)"(.*)$/, '\1\"\2')
    else
      str
    end
  end
end
