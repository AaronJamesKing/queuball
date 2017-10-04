require 'test_helper'
require 'time'
require 'spotify'

class PlaylistSessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    SpotifyService.stubs(:get_user_info).with {|*args| args[0]=='ACCESS_TOKEN1'}.returns({
      "display_name" => "User One",
      "id" => "spotify_user1"
    });
    SpotifyService.stubs(:get_user_info).with {|*args| args[0]=='ACCESS_TOKEN2'}.returns({
      "display_name" => "User Two",
      "id" => "spotify_user2"
    });

    SpotifyService.stubs(:get_token_response).with {|*args| args[0]=='TOKEN1'}.returns({
      "access_token" => "ACCESS_TOKEN1",
      "refresh_token" => "REFRESH_TOKEN1",
      "expires_in" => 3600
    });
    SpotifyService.stubs(:get_token_response).with {|*args| args[0]=='TOKEN2'}.returns({
      "access_token" => "ACCESS_TOKEN2",
      "refresh_token" => "REFRESH_TOKEN2",
      "expires_in" => 3600
    });

    # Create two Users and authenticate one
    get auth_callback_url + "?code=TOKEN2"
    @other_user = User.find_by(spotify_id: "spotify_user2")

    get auth_callback_url + "?code=TOKEN1"
    @user = User.find_by(spotify_id: "spotify_user1")

    # create some Playlist Sessions associated with the user
    @ps1 = @user.playlist_sessions.create!(name: "playlist_1")
    @ps2 = @user.playlist_sessions.create!(name: "playlist_2")
  end

  test "Index lists all of the user's Playlist Sessions" do
    get playlist_sessions_url
    assert_select "ul li.playlist-session", 2
  end

  test "Playlist Session page shows correct details" do
    get playlist_session_url(@ps1)
    assert_select "h1", @ps1.name
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
    assert_redirected_to playlist_session_url(@ps.id)
  end

  test "Failing to create a Session Playlist returns to the New Playlist Session page and displays error messages" do
    post playlist_sessions_url, :params => {playlist_session: {name: "", user_id: @user.id}}
    assert_response 400
    assert_select "div.field_with_errors"
  end

  test "User can delete a Playlist Session" do
    delete playlist_session_url(@ps2.id)
    assert_redirected_to playlist_sessions_url
    assert_nil PlaylistSession.find_by(id: @ps2.id)
  end
end
