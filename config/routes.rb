Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :api do
    namespace :v1 do
      post   "signup",  to: "auth#signup"
      post   "login",   to: "auth#login"
      get    "me",      to: "users#me"
      delete "logout",  to: "auth#logout"

      resources :job_applications, only: [:index, :create, :show, :update, :destroy]
      resources :follow_ups,       only: [:index, :create, :update, :destroy]
      resource  :home_summary,     only: [:show], controller: "home_summary"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end