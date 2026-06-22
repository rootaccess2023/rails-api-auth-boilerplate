module Api
  module V1
    class FollowUpsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_follow_up, only: [:update, :destroy]

      # GET /api/v1/follow_ups — open only; client groups into overdue/today/upcoming
      def index
        follow_ups = current_user.follow_ups
                                 .open
                                 .includes(job_application: :company)
                                 .ordered
        render json: follow_ups.map { |f| serialize(f) }
      end

      # POST /api/v1/follow_ups
      # Params: title, due_at, application_slug (optional)
      def create
        follow_up = current_user.follow_ups.build(follow_up_params)

        if params[:application_slug].present?
          app = current_user.job_applications.find_by(slug: params[:application_slug])
          return render json: { error: "Application not found" }, status: :not_found unless app
          follow_up.job_application = app
        end

        if follow_up.save
          render json: serialize(follow_up), status: :created
        else
          render json: { errors: follow_up.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/follow_ups/:id
      # Params: title?, due_at?, completed? (boolean toggle)
      def update
        if params.key?(:completed)
          @follow_up.completed_at = params[:completed] ? Time.current : nil
        end

        @follow_up.assign_attributes(follow_up_params)

        if @follow_up.save
          render json: serialize(@follow_up)
        else
          render json: { errors: @follow_up.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/follow_ups/:id
      def destroy
        @follow_up.destroy
        head :no_content
      end

      private

      def set_follow_up
        @follow_up = current_user.follow_ups.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Not found" }, status: :not_found
      end

      def follow_up_params
        params.permit(:title, :due_at)
      end

      def serialize(f)
        {
          id:           f.id,
          title:        f.title,
          due_at:       f.due_at.iso8601,
          completed_at: f.completed_at&.iso8601,
          job_application: f.job_application ? {
            slug:       f.job_application.slug,
            role_title: f.job_application.role_title,
            company:    { name: f.job_application.company.name }
          } : nil
        }
      end
    end
  end
end
