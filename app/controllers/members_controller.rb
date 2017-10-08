class MembersController < ApplicationController
  before_action :find_member, only: [:update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def new
    @member = Member.new(user_id: current_user().id)
  end

  def invite
    @member_params = params.require(:member).permit(:user_spotify_id, :playlist_id, :invited_by)
    @user = User.find_by(spotify_id: @member_params[:user_spotify_id])
    @member_params = {
      user_id: @user.id,
      playlist_id: params[:playlist_id],
      invited_by: current_user.id
    }
    @member = Member.new(@member_params)
    if @member.save  
      redirect_to playlist_url(params[:playlist_id])
    else
      render "new", :status => 400
    end
  end

  def update
    @member_params = params.require(:member).permit(:accepted_by)
    @member.update(@member_params)
    if @member.valid?  
      redirect_to playlist_url(params[:playlist_id])
    else
      render "new", :status => 400
    end
  end

  def destroy
    if @member.destroy
      redirect_to playlist_url(params[:playlist_id])
    else
      render "500.html", status: 500
    end
  end

private

  def find_member
    @member = Member.find_by!(id: params[:id])
  end

  def not_found
    render "404.html", status: 404
  end
end
