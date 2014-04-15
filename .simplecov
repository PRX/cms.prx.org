SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter

SimpleCov.use_merging true
SimpleCov.merge_timeout 3600

SimpleCov.start('rails') do
  add_filter '/db/'
  add_filter '/test/'
  add_filter '/config/'
  add_filter '/lib/'
  add_filter '/vendor/'

  add_group 'Controllers', 'app/controllers'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'
  add_group 'Models', 'app/models'
  add_group 'Representers', 'app/representers'
  add_group 'Uploaders', 'app/uploaders'
  add_group 'Views', 'app/views'
end
