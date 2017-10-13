require 'test_helper'
require 'time'
require 'spotify'

class PlaylistsControllerTest < ActionDispatch::IntegrationTest
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

    # create some Playlists associated with the user
    @ps1 = @user.playlists.create!(name: "playlist_1")
    #@ps2 = @user.playlists.create!(name: "playlist_2")
  end

  test "Index lists all of the user's Playlists" do
    get playlists_url
    assert_select "ul li.playlist", 1
  end

  test "Playlist page shows correct details" do
    get playlist_url(@ps1)
    assert_select "h1", @ps1.name
  end

  test "New Playlist page contains all the necessary fields to create a new Playlist" do
    get new_playlist_url
    assert_select "form" do
      assert_select "input[id=playlist_user_id]"
      assert_select "input[type=hidden]"
    end
  end

  test "User can create a new Playlist which redirects to that Playlist" do
    @ps = @user.playlists.new(name: "Newest Playlist")
    post playlists_url, params: {playlist: @ps.attributes}
    @ps = Playlist.find_by(name: "Newest Playlist")
    assert_redirected_to playlist_url(@ps.id)
  end

  test "Failing to create a Playlist returns to the New Playlist page and displays error messages" do
    post playlists_url, :params => {playlist: {name: "", user_id: @user.id}}
    assert_response 400
    assert_select "div.field_with_errors"
  end

  test "User can delete a Playlist" do
    delete playlist_url(@ps1.id)
    assert_redirected_to playlists_url
    assert_nil Playlist.find_by(id: @ps1.id)
  end

  test "Playlist owner can invite another User to be a Playlist Member, and they can accept it" do
    # Invite the user to be a member
    post playlist_invite_url(@ps1.id), :params => {member: {user_spotify_id: @other_user.spotify_id}}
    @member = Member.find_by!(user_id: @other_user.id, playlist_id: @ps1.id)
    assert_select "ul li.member", 0

    # Accept the membership
    put playlist_member_url(@ps1.id, @member.id), :params => {member: {accepted_by: @other_user.id}}
    assert_not_nil Member.find_by(user_id: @other_user.id, playlist_id: @ps1.id, accepted_by: @other_user.id)
    follow_redirect!
    assert_select "ul li.member", 1
  end

  test "Non-Members cannot view a Playlist" do
    # Sign User2 in
    get auth_callback_url + "?code=TOKEN2"
    # Go to unauthorized Playlist
    get playlist_url(@ps1.id)
    assert_response 401
    # Authorize
    Member.create!(user_id: @other_user.id, playlist_id: @ps1.id, invited_by: @user.id, accepted_by: @other_user.id)
    # Retry
    get playlist_url(@ps1.id)
    assert_response 200
  end
end
