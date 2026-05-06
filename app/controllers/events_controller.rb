class EventsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create ]

  def index
    @events = Event.order(:starts_at)
  end

  def show
    @event = Event.find(params[:id])
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
    params.expect(event: [ :title, :description, :starts_at, :location ])
  end
end
