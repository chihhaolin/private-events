class EventRegistrationsController < ApplicationController
  before_action :authenticate_user!

  def create
    event = Event.find(params[:event_id])
    return redirect_to root_path, alert: "That event is private." unless event.visible_to?(current_user)

    current_user.registrations.find_or_create_by(event: event)
    redirect_to event, notice: "You're registered."
  end

  def destroy
    event = Event.find(params[:event_id])
    current_user.registrations.where(event: event).destroy_all
    redirect_to event, notice: "Registration cancelled."
  end
end
