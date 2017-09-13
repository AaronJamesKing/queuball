module SpotifyService

  SpotifyRedirectUri = "http://localhost:3000/auth/callback/"

  def SpotifyService.get_token_response(code)
    @token_params = {
      'grant_type' => 'authorization_code',
      'code' => code,
      'redirect_uri' => SpotifyRedirectUri,
      'client_id' => 'e6f13cbb22ef4cecb1bfafa4312d7bb1',
      'client_secret' => '0cd9bcedf3244563ab8249fdfe582e88'
    }
    @token_response = Net::HTTP.post_form(URI.parse('https://accounts.spotify.com/api/token'), @token_params)

    return ActiveSupport::JSON.decode(@token_response.body)
  end

  def SpotifyService.get_user_info(token)
    @uri = URI.parse('https://api.spotify.com/v1/me')
    @http = Net::HTTP.new(@uri.host, @uri.port)
    @http.use_ssl = true

    @user_request = Net::HTTP::Get.new(@uri.request_uri)
    @user_request["Authorization"] = "Bearer " + token
    @user_response = @http.request(@user_request)

    return ActiveSupport::JSON.decode(@user_response.body)
  end
end
