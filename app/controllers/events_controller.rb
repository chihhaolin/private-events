class EventsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create ]

  def index
    visible = visible_events
    @upcoming_events = visible.upcoming.order(:starts_at)
    @past_events     = visible.past.order(starts_at: :desc)
  end

  def show
    @event = Event.find(params[:id])
    return if @event.visible_to?(current_user)
    redirect_to root_path, alert: "That event is private."
  end

  def new
    @event = current_user.created_events.build
  end

  def create
    @event = current_user.created_events.build(event_params)
    if @event.save
      redirect_to @event, notice: "Event created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def event_params
    params.expect(event: [ :title, :description, :starts_at, :location, :private ])
  end

  # Public events are always visible. Private events are visible only to the
  # creator, the invitees, and current attendees.
  def visible_events
    return Event.where(private: false) unless current_user

    Event.where(
      "events.private = :public OR events.creator_id = :uid " \
      "OR events.id IN (:invited_ids) OR events.id IN (:attended_ids)",
      public: false,
      uid: current_user.id,
      invited_ids: current_user.invited_events.select(:id),
      attended_ids: current_user.attended_events.select(:id)
    )
  end
end
