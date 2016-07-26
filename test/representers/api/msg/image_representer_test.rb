require 'test_helper'

describe Api::Msg::ImageRepresenter do

  let(:representer) { Api::Msg::ImageRepresenter.new(image) }
  let(:json)        { JSON.parse(representer.to_json) }

  describe 'with a completed upload' do

    let(:image) { FactoryGirl.create(:story_image) }

    it 'includes basic data' do
      json['id'].must_equal image.id
      json['filename'].must_equal 'test.png'
      json['size'].must_be_nil
      json['caption'].must_be_nil
      json['credit'].must_be_nil
      json['status'].must_equal image.status
    end

    it 'has no uploaded path' do
      json['uploadPath'].must_be_nil
    end

    it 'has a destination path' do
      json['destinationPath'].must_equal "public/piece_images/#{image.id}"
    end

  end

  describe 'with an in-progress upload' do

    let(:image) { FactoryGirl.create(:story_image_uploaded) }

    it 'includes basic data' do
      json['id'].must_equal image.id
      json['filename'].must_equal 'test.jpg'
      json['size'].must_be_nil
      json['caption'].must_be_nil
      json['credit'].must_be_nil
      json['status'].must_equal image.status
    end

    it 'has the uploaded path' do
      json['uploadPath'].must_equal image.upload_path
    end

    it 'has a destination path' do
      json['destinationPath'].must_equal "public/piece_images/#{image.id}"
    end

  end

end
