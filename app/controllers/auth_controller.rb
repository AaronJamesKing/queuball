class AuthController < ApplicationController
  require "uri"
  require "net/http"
  require "base64"
  require "time"

  def index
    spotify_params = {
      client_id: 'e6f13cbb22ef4cecb1bfafa4312d7bb1', 
      response_type: 'code',
      redirect_uri: spotify_redirect_uri,
      scope: 'playlist-read-private playlist-modify-public playlist-modify-private user-read-private'
    }.to_param
    @spotify_auth_url = "https://accounts.spotify.com/authorize/?" + spotify_params
  end

  
  def callback
    if (params.has_key?(:code))
      user_fields = get_user_fields(params[:code])
      Rails.logger.debug user_fields
      user = create_user(user_fields)
      if (user != nil)
        redirect_to playlist_session_index_url
      else
        redirect_to action: "index"
      end
    elsif (params.has_key?(:error))
      redirect_to action: "index"
    else
      render :file => "public/500.html", :status => 400
    end
  end


  protected

  def get_user_fields(code)
    timestamp = Time.now.getutc.to_i

    # Get authorization token and refresh token
    token_json = get_token_reponse(code)
    token = token_json["access_token"]

    # Get user info
    user_json = get_user_info(token)

    user_fields = Hash.new
    user_fields[:access_token] = token
    user_fields[:refresh_token] = token_json["refresh_token"]
    user_fields[:expires_in] = token_json["expires_in"]
    user_fields[:authorized_at] = timestamp
    user_fields[:display_name] = user_json["display_name"]
    user_fields[:spotify_id] = user_json["id"]
  end


  def spotify_redirect_uri
    return "http://localhost:3000/auth/callback/"
  end

  
  def get_token_reponse(code)
    token_params = {
      'grant_type' => 'authorization_code',
      'code' => code,
      'redirect_uri' => spotify_redirect_uri,
      'client_id' => 'e6f13cbb22ef4cecb1bfafa4312d7bb1',
      'client_secret' => '0cd9bcedf3244563ab8249fdfe582e88'
    }
    token_response = Net::HTTP.post_form(URI.parse('https://accounts.spotify.com/api/token'), token_params)

    return ActiveSupport::JSON.decode(token_response.body)
  end


  def get_user_info(token)
    uri = URI.parse('https://api.spotify.com/v1/me')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    user_request = Net::HTTP::Get.new(uri.request_uri)
    user_request["Authorization"] = "Bearer " + token
    user_response = http.request(user_request)

    return ActiveSupport::JSON.decode(user_response.body)
  end
end
