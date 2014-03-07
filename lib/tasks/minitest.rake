if defined?(MiniTest)
  MiniTest::Rails::Testing.default_tasks << 'representers'
  MiniTest::Rails::Testing.default_tasks << 'uploaders'
end