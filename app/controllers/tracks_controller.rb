class TracksController < ApplicationController
  before_action :find_track, only: [:update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def new
    @playlist_id = params[:playlist_id]
    render "search"
  end

  def create
    @track_params = params.require(:track).permit(:spotify_id, :name, :artists_text, :album_name, :duration)
    @track_params[:playlist_id] = params[:playlist_id]
    @track_params[:user_id] = current_user.id
    @track = Track.new(@track_params)
    if @track.save  
      redirect_to playlist_url(params[:playlist_id])
    else
      render "new", :status => 400
    end
  end

  def search
    nil
  end

  def update
    @track_params = params.require(:track).permit(:accepted_by)
    @track.update(@track_params)
    if @track.valid?  
      redirect_to playlist_url(params[:playlist_id])
    else
      render "new", :status => 400
    end
  end

  def destroy
    if @track.destroy
      redirect_to playlist_url(params[:playlist_id])
    else
      render "500.html", status: 500
    end
  end

private

  def find_track
    @track = Track.find_by!(id: params[:id])
  end

  def not_found
    render "404.html", status: 404
  end
end
