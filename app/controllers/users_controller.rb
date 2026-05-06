class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @created_events  = @user.created_events.order(:starts_at)
    @attended_events = @user.attended_events.order(:starts_at)
  end
end
