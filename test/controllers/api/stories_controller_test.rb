require 'test_helper'

describe Api::StoriesController do

  let(:story) { create(:story) }

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', id: story.id } )
    assert_response :success
  end

  it 'should list' do
    story.must_be :published
    get(:index, { api_version: 'v1', format: 'json' } )
    assert_response :success
  end

  it 'should list highlighted stories' do
    portfolio = create(:portfolio)
    playlist_section = create(:playlist_section, playlist: portfolio)
    pick1 = create(:pick, story: story, playlist_section: playlist_section)
    pick2 = create(:pick)
    get(:index, { api_version: 'v1',
                  format: 'json',
                  account_id: portfolio.account_id,
                  filters: 'highlighted'})

    assert_response :success
    assert_not_nil assigns[:stories]
    assigns[:stories].must_include story
    assigns[:stories].wont_include pick2.story
  end

  it 'should error on bad version' do
    get(:index, { api_version: 'v2', format: 'json' } )
    assert_response :not_acceptable
  end

end
