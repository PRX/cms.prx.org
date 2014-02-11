require "test_helper"

describe AudioFile do
  it "has a table defined" do
    AudioFile.table_name.must_equal 'audio_files'
  end
end
