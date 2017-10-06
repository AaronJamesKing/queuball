class MembersController < ApplicationController
  before_action :find_member, only: [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def new
    @member = Member.new(user_id: current_user().id)
  end

  def create
    #@member_params = params.require(:member).permit(:user_id, :playlist_id, :invited_by)
    @member_params = params.require(:user_spotify_id)
    @member = Member.new(@member_params)
    if @member.save  
      #redirect_to action: "show", id: @member.id
    else
      render "new", :status => 400
    end
  end

  def update
    nil
  end

  def destroy
    if @member.destroy
      #redirect_to action: "index"
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
