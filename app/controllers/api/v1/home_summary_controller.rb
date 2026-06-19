module Api
  module V1
    class HomeSummaryController < ApplicationController
      before_action :authenticate_user!

      # Days in "applied" status before an application is considered stale.
      # Tune this to change the threshold across the whole feature.
      STALE_AFTER_DAYS = 7

      # GET /api/v1/home_summary
      def show
        render json: {
          counts:             counts_data,
          stale_applications: stale_applications_data,
          recent_activity:    recent_activity_data
        }
      end

      private

      def counts_data
        apps = current_user.job_applications
        {
          total:        apps.count,
          this_week:    apps.where(created_at: 7.days.ago..).count,
          applied:      apps.where(status: :applied).count,
          screening:    apps.where(status: :screening).count,
          interviewing: apps.where(status: :interviewing).count,
          offer:        apps.where(status: :offer).count
        }
      end

      def stale_applications_data
        cutoff = STALE_AFTER_DAYS.days.ago.to_date

        apps = current_user.job_applications
                           .includes(:company)
                           .where(status: :applied)
                           .where(
                             "applied_on < :cutoff OR (applied_on IS NULL AND DATE(created_at) < :cutoff)",
                             cutoff: cutoff
                           )
                           .order(Arel.sql("COALESCE(applied_on, DATE(created_at)) ASC"))
                           .limit(3)

        apps.map do |app|
          effective_date = app.applied_on || app.created_at.to_date
          {
            slug:       app.slug,
            role_title: app.role_title,
            status:     app.status,
            applied_on: app.applied_on,
            days_since: (Date.current - effective_date).to_i,
            company:    { name: app.company.name }
          }
        end
      end

      def recent_activity_data
        changes = StatusChange
                    .joins(job_application: :company)
                    .where(job_applications: { user_id: current_user.id })
                    .includes(job_application: :company)
                    .order(changed_at: :desc)
                    .limit(5)

        changes.map do |sc|
          app = sc.job_application
          {
            from_status: sc.from_status,
            to_status:   sc.to_status,
            changed_at:  sc.changed_at.iso8601,
            slug:        app.slug,
            role_title:  app.role_title,
            company:     { name: app.company.name }
          }
        end
      end
    end
  end
end
