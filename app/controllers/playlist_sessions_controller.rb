class PlaylistSessionsController < ApplicationController
  def index
    @playlist_sessions = PlaylistSession.where(user_id: current_user().id)
  end

  def show
    @playlist_session = PlaylistSession.find_by(id: parameters[:id])
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
    nil
  end
end
