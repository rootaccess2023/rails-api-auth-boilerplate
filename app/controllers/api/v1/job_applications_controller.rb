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
        application = current_user.job_applications
                                  .includes(:company, :status_changes)
                                  .find_by!(slug: params[:id])
        render json: serialize(application, include_history: true)
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

      # PATCH /api/v1/job_applications/:id  (status-only update)
      def update
        application = current_user.job_applications
                                  .includes(:company)
                                  .find_by!(slug: params[:id])

        new_status = params[:status].to_s

        unless JobApplication.statuses.key?(new_status)
          return render json: { error: "Invalid status '#{new_status}'" }, status: :unprocessable_entity
        end

        # No-op: same status — don't write a history row
        if application.status == new_status
          return render json: serialize(application, include_history: true)
        end

        from_status = application.status

        ApplicationRecord.transaction do
          application.update!(status: new_status)
          application.status_changes.create!(
            from_status: from_status,
            to_status:   new_status,
            changed_at:  Time.current
          )
        end

        # Reload clears preloaded associations; serializer fetches fresh data on demand
        application.reload
        render json: serialize(application, include_history: true)
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Not found" }, status: :not_found
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      private

      def application_params
        params.permit(:role_title, :status, :location, :source, :applied_on)
      end

      def serialize(app, include_history: false)
        data = {
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

        if include_history
          data[:status_changes] = app.status_changes.map do |sc|
            {
              id:          sc.id,
              from_status: sc.from_status,  # enum accessor returns string or nil
              to_status:   sc.to_status,    # enum accessor returns string
              changed_at:  sc.changed_at.iso8601
            }
          end
        end

        data
      end
    end
  end
end
