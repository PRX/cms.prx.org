# Wrapper for string that is already json
# inspired by: http://grosser.it/2013/10/16/compiled-json-for-partially-cached-json-response-precompiled-handlebar-templates/
class Caches::SerializedJson < Object
  def initialize(s); @s = s; end
  def to_json(*args); @s; end
  def to_s; @s; end

  undef_method :as_json
end
