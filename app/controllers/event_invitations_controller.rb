class EventInvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_event_and_authorize_creator

  def create
    invitee = User.find_by(email: params[:email].to_s.downcase.strip)
    return redirect_to @event, alert: "No user with that email." if invitee.nil?
    return redirect_to @event, alert: "Can't invite the creator." if invitee == @event.creator

    @event.invitations.find_or_create_by(invitee: invitee)
    redirect_to @event, notice: "#{invitee.name} invited."
  end

  def destroy
    @event.invitations.find(params[:id]).destroy
    redirect_to @event, notice: "Invitation removed."
  end

  private

  def load_event_and_authorize_creator
    @event = Event.find(params[:event_id])
    return if @event.creator == current_user
    redirect_to @event, alert: "Only the creator can manage invitations."
  end
end
