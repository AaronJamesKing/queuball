class PlaylistsController < ApplicationController
  before_action :find_playlist, only: [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def index
    @playlists = Playlist.where(user_id: current_user().id)
  end

  def show
    nil
  end

  def new
    @playlist = Playlist.new(user_id: current_user().id)
  end

  def create
    @ps_params = params.require(:playlist).permit(:user_id, :name)
    @playlist = Playlist.new(@ps_params)
    if @playlist.save  
      redirect_to action: "show", id: @playlist.id
    else
      #@playlist.errors.full_messages.each do |message|
      #  puts message
      #end
      render "new", :status => 400
    end
  end

  def update
    nil
  end

  def destroy
    if @playlist.destroy
      redirect_to action: "index"
    else
      render "500.html", status: 500
    end
  end

private

  def find_playlist
    @playlist = Playlist.find_by!(id: params[:id])
  end

  def not_found
    render "404.html", status: 404
  end
end
