class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])

    @upcoming_created  = @user.created_events.upcoming.order(:starts_at)
    @past_created      = @user.created_events.past.order(starts_at: :desc)

    @upcoming_attended = @user.attended_events.upcoming.order(:starts_at)
    @past_attended     = @user.attended_events.past.order(starts_at: :desc)

    if current_user == @user
      @upcoming_invited = @user.invited_events.upcoming.order(:starts_at)
      @past_invited     = @user.invited_events.past.order(starts_at: :desc)
    end
  end
end
