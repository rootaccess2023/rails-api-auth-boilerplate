module Api
  module V1
    class JobApplicationsController < ApplicationController
      before_action :authenticate_user!

      # GET /api/v1/job_applications
      def index
        applications = current_user.job_applications
                                   .includes(:company)
                                   .order(created_at: :desc)
        render json: applications.map { |app| serialize(app) }
      end

      # GET /api/v1/job_applications/:id  (:id is the slug)
      def show
        application = current_user.job_applications.includes(:company).find_by!(slug: params[:id])
        render json: serialize(application)
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Not found" }, status: :not_found
      end

      # POST /api/v1/job_applications
      def create
        company = current_user.companies.find_or_create_by(name: params[:company_name].to_s.strip)
        unless company.persisted?
          return render json: { errors: company.errors.full_messages }, status: :unprocessable_entity
        end

        application = current_user.job_applications.build(application_params)
        application.company = company

        if application.save
          render json: serialize(application), status: :created
        else
          render json: { errors: application.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def application_params
        params.permit(:role_title, :status, :location, :source, :applied_on)
      end

      def serialize(app)
        {
          id:         app.id,
          slug:       app.slug,
          role_title: app.role_title,
          status:     app.status,
          location:   app.location,
          source:     app.source,
          applied_on: app.applied_on,
          created_at: app.created_at.iso8601,
          company: {
            id:   app.company.id,
            name: app.company.name
          }
        }
      end
    end
  end
end
