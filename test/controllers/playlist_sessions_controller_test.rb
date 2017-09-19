require 'test_helper'
require 'time'

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
    @ps1 = PlaylistSession.create({user_id: "spotify_user"})
    @ps2 = PlaylistSession.create({user_id: "spotify_user"})
  end

  test "Index lists all of the user's Playlist Sessions" do
    get playlist_sessions_url
    assert_select "ul li.playlist_session", 2
  end

  test "New Playlist Session page contains all the necessary fields to create a new Playlist Session" do
    get new_playlist_session_url
    assert_select "form" do
      assert_select "input[name=something]"
    end
  end

  test "User can create a new Playlist Session" do
    @ps = PlaylistSession.new(user_id: @user.id, name: "Newest Playlist")
    post playlist_sessions_url, params: @ps.attributes
    @ps = PlaylistSession.find_by(name: "Newest Playlist")
    assert @ps != nil
  end

  test "Creating a new Playlist Session redirects to the Index page" do
    post playlist_sessions_url, params: {}
    assert_response 302
    assert_redirected_to playlist_sessions_url
  end

  test "Failing to create a Session Playlist returns to the New Playlist Session page and displays error messages" do
    post playlist_sessions_url, params: {"bad" => "wrong"}
    assert_response 400
    assert_redirected_to new_playlist_session_url
    assert_select "div.error"
  end
end
