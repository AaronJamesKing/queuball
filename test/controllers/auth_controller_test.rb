require 'test_helper'

class AuthControllerTest < ActionDispatch::IntegrationTest
  test "landing page should redirect when user is already authenticated" do
    get auth_index_url
    login_for_testing
    assert_redirected_to controller: "playlist_session", action: "index"
  end

  test "landing page should include link to Spotify's Authorization endpoint" do
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
end
