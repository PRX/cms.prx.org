require "test_helper"

describe AudioVersion do
  before do
    @audio_version = AudioVersion.new
  end

  it "has a table defined" do
    AudioVersion.table_name.must_equal 'audio_versions'
  end
end
