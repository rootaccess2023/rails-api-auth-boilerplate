class Api::V1::ApplicationEventsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_job_application

  def index
    events = @job_application.application_events.order(starts_at: :asc)
    render json: { events: events }, status: :ok
  end

  def create
    event = @job_application.application_events.new(event_params)
    event.user = current_user

    if event.save
      render json: { event: event }, status: :created
    else
      render json: { errors: event.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    event = @job_application.application_events.find(params[:id])

    if event.update(event_params)
      render json: { event: event }, status: :ok
    else
      render json: { errors: event.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    event = @job_application.application_events.find(params[:id])
    event.destroy
    head :no_content
  end

  private

  def set_job_application
    @job_application = current_user.job_applications.find_by!(slug: params[:slug])
  end

  def event_params
    params.require(:event).permit(
      :title,
      :event_type,
      :starts_at,
      :ends_at,
      :all_day,
      :location,
      :meeting_url,
      :notes,
      :status,
      :reminder_minutes_before
    )
  end
end