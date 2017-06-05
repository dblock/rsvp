class RsvpsController < ApplicationController
  before_action :set_event, only: [:new, :create, :thank_you]

  # GET /rsvps/new
  def new
    @rsvp = Rsvp.new name: params[:name], email: params[:email]
  end

  # POST /rsvps
  # POST /rsvps.json
  def create
    @rsvp = Constellation.create_rsvp!(rsvp_params.merge event_id: @event.id)
    respond_to do |format|
      format.html { redirect_to thank_rsvp_url(@event) }
    end
  rescue ::ConstellationHttpException => e
    respond_to do |format|
      # Add some locals that simple form expects (+ errors)
      @rsvp = Rsvp.new
      @error = e.message
      format.html { render :new }
    end
  end

  def thank_you
  end

  private
    def set_event
      @event = Event.friendly.find(params[:event_id])
    end

    def rsvp_params
      params[:rsvp][:guests] = []
      params[:guest_names]&.each_with_index do |name, idx|
        params[:rsvp][:guests] << { name: name, email: params[:guest_emails][idx] }
      end
      params.require(:rsvp).permit(:name, :email, guests: [:name, :email])
    end
end
