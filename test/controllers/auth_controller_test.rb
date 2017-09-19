require 'test_helper'
require 'spotify'

class AuthControllerTest < ActionDispatch::IntegrationTest
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
  end

  test "landing page redirects when user is already authenticated" do
    get auth_callback_url + "?code=good_code"
    controller.session[:current_user_id] = "spotify_user"
    get auth_index_url
    assert_redirected_to controller: "playlist_sessions", action: "index"
  end

  test "landing page includes link to Spotify's Authorization endpoint" do
    get auth_index_url
    assert_select "a", :href => /accounts\.spotify\.com\/authorize/
  end

  test "callback without `code`/`error` and `state` params redirects to error page" do
    get auth_callback_url
    assert_response 400
  end

  test "callback with `error` parameter redirects to landing page" do
    get auth_callback_url + "?error=access_denied"
    assert_redirected_to controller: "auth", action: "index"
  end

  test "callback with valid access code persists a new User to the database" do
    get auth_callback_url + "?code=good_code"
    @user = User.find_by(spotify_id: "spotify_user")
    assert @user != nil
  end

  test "successful authentication adds an auth cookie to the session" do
    get auth_callback_url + "?code=good_code"
    assert controller.session[:current_user_id] == "spotify_user"
  end

  test "successful authentication redirects the user to the Playlist Session index page" do
    get auth_callback_url + "?code=good_code"
    assert_response 302
  end

  test "authenticated user can log out, which deletes the session cookie" do
    get auth_callback_url + "?code=good_code"
    get auth_logout_url
    assert controller.session[:current_user_id] == nil
  end
end
