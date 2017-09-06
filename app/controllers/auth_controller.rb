class AuthController < ApplicationController
  require "time"
  require "spotify"

  def index
    spotify_params = {
      client_id: 'e6f13cbb22ef4cecb1bfafa4312d7bb1', 
      response_type: 'code',
      redirect_uri: SpotifyService.spotify_redirect_uri,
      scope: 'playlist-read-private playlist-modify-public playlist-modify-private user-read-private'
    }.to_param
    @spotify_auth_url = "https://accounts.spotify.com/authorize/?" + spotify_params
  end

  def callback
    if (params.has_key?(:code))
      @user_fields = get_user_fields(params[:code])
      @user = User.find_or_initialize_by(spotify_id: @user_fields[:spotify_id])
      @success = @user.update(@user_fields)
      if (@success)
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
    @timestamp = Time.now.getutc

    # Get authorization token and refresh token
    @token_json = SpotifyService.get_token_reponse(code)
    @token = @token_json["access_token"]

    # Get user info
    @user_json = SpotifyService.get_user_info(@token)

    @user_fields = {
      :access_token => @token,
      :refresh_token => @token_json["refresh_token"],
      :expires_in => @token_json["expires_in"],
      :authorized_at => @timestamp,
      :display_name => @user_json["display_name"],
      :spotify_id => @user_json["id"],
    }

    return @user_fields
  end
end