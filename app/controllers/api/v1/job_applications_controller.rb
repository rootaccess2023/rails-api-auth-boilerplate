class Api::V1::JobApplicationsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_job_application, only: [:show, :update, :destroy]

  def index
    job_applications = current_user.job_applications.order(created_at: :desc)
    render json: job_applications, status: :ok
  end

  def show
    render json: @job_application, status: :ok
  end

  def create
    job_application = current_user.job_applications.new(job_application_params)

    if job_application.save
      render json: job_application, status: :created
    else
      render json: { errors: job_application.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    if @job_application.update(job_application_params)
      render json: @job_application, status: :ok
    else
      render json: { errors: @job_application.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    @job_application.destroy
    head :no_content
  end

  private

  def set_job_application
    @job_application = current_user.job_applications.find(params[:id])
  end

  def job_application_params
    params.require(:job_application).permit(
      :company,
      :job_title,
      :job_url,
      :location,
      :source,
      :stage,
      :notes
    )
  end
end