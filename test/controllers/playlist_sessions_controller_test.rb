require 'test_helper'
require 'time'
require 'spotify'

class PlaylistSessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    SpotifyService.stubs(:get_user_info).returns({
      "display_name" => "Spotify User",
      "id" => "spotify_user"
    });

    SpotifyService.stubs(:get_token_response).returns({
      "access_token" => "ACCESS_TOKEN",
      "refresh_token" => "REFRESH_TOKEN",
      "expires_in" => 3600
    });

    # Create and authenticate a User
    get auth_callback_url + "?code=good_code"
    @user = User.find_by(spotify_id: "spotify_user")

    # create some Playlist Sessions associated with the user
    @ps1 = @user.playlist_sessions.create!(name: "playlist_1")
    @ps2 = @user.playlist_sessions.create!(name: "playlist_2")
  end

  test "Index lists all of the user's Playlist Sessions" do
    get playlist_sessions_url
    #puts @response.body
    assert_select "ul li.playlist-session", 2
  end

  test "New Playlist Session page contains all the necessary fields to create a new Playlist Session" do
    get new_playlist_session_url
    assert_select "form" do
      assert_select "input[id=playlist_session_user_id]"
      assert_select "input[type=hidden]"
    end
  end

  test "User can create a new Playlist Session which redirects to that Playlist Session" do
    @ps = @user.playlist_sessions.new(name: "Newest Playlist")
    post playlist_sessions_url, params: {playlist_session: @ps.attributes}
    @ps = PlaylistSession.find_by(name: "Newest Playlist")
    assert_response 302
    assert_redirected_to playlist_session_url(@ps.id)
  end

  test "Failing to create a Session Playlist returns to the New Playlist Session page and displays error messages" do
    post playlist_sessions_url, :params => {playlist_session: {name: "", user_id: @user.id}}
    assert_response 400
    assert_select "div.field_with_errors"
  end
end
