class PlaylistSessionsController < ApplicationController
  before_action :find_playlist_session, only: [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def index
    @playlist_sessions = PlaylistSession.where(user_id: current_user().id)
  end

  def show
    nil
  end

  def new
    @playlist_session = PlaylistSession.new(user_id: current_user().id)
  end

  def create
    @ps_params = params.require(:playlist_session).permit(:user_id, :name)
    @playlist_session = PlaylistSession.new(@ps_params)
    if @playlist_session.save  
      redirect_to action: "show", id: @playlist_session.id
    else
      #@playlist_session.errors.full_messages.each do |message|
      #  puts message
      #end
      render "new", :status => 400
    end
  end

  def update
    nil
  end

  def destroy
    if @playlist_session.destroy
      redirect_to action: "index"
    else
      render "500.html", status: 500
    end
  end

private

  def find_playlist_session
    @playlist_session = PlaylistSession.find_by!(id: params[:id])
  end

  def not_found
    render "404.html", status: 404
  end
end
