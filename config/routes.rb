Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :api do
    namespace :v1 do
      # Auth
      post   "signup",  to: "auth#signup"
      post   "login",   to: "auth#login"
      get    "me",      to: "users#me"
      delete "logout",  to: "auth#logout"

      # Job Applications
      get    "job_applications",     to: "job_applications#index"
      get    "job_applications/:slug", to: "job_applications#show"
      post   "job_applications",      to: "job_applications#create"
      patch  "job_applications/:slug", to: "job_applications#update"
      delete "job_applications/:slug", to: "job_applications#destroy"

      # Application Events
      get    "job_applications/:slug/events",     to: "application_events#index"
      post   "job_applications/:slug/events",     to: "application_events#create"
      patch  "job_applications/:slug/events/:id", to: "application_events#update"
      delete "job_applications/:slug/events/:id", to: "application_events#destroy"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end