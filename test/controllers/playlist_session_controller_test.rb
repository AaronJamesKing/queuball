require 'test_helper'

class PlaylistSessionControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get playlist_session_index_url
    assert_response :success
  end

end
