require "test_helper"

describe AudioVersion do
  it "has a table defined" do
    AudioVersion.table_name.must_equal 'audio_versions'
  end
end
