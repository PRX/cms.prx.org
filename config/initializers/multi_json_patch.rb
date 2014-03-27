# Code from http://devblog.agworld.com.au/post/42586025923/the-performance-of-to-json-in-rails-sucks-and-theres
# essentially reversing Rails' hard-coded call to ActiveSupport::JSON.encode
[Object, Array, FalseClass, Float, Hash, Integer, NilClass, String, TrueClass].each do |klass|
  klass.class_eval do
    def to_json(opts = {})
      Rails.logger.debug("MultiJsonPatch: options: #{opts.inspect}")
      opts[:indent] = opts[:indent] || 0
      MultiJson::dump(self.as_json(opts), opts)
    end
  end
end
