require 'test_helper'
require 'spotify'

class PlaylistsTrackControllerTest < ActionDispatch::IntegrationTest
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

    get auth_callback_url + "?code=TOKEN1"
    @user = User.find_by(spotify_id: "spotify_user1")
    
    # create a Playlist associated with the user
    @playlist = @user.playlists.create!(name: "playlist_1")
  end

  test "Render form for new Track prior to search" do
    get new_playlist_track_url(@playlist.id)
    assert_select "form div.track-search"
    assert_select "ul li.track", 0
  end

  test "Render form for new Track with options after search" do
    post tracks_search_url, :params => {query: "Bird's Lament"}
    assert_select "form div.track-search"
    assert_select "ul li.track", {minimum: 1, maximum: 50}
  end

  test "Added Track appears on Playlist page" do
    post playlist_tracks_url(@playlist.id), :params => {track: 
    {
      spotify_id: "",
      name: "",
      artists_text: "",
      album_name: "",
      duration: 10,
    }}
  end
end
