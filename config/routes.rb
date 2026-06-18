Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :api do
    namespace :v1 do
      post   "signup",  to: "auth#signup"
      post   "login",   to: "auth#login"
      get    "me",      to: "users#me"
      delete "logout",  to: "auth#logout"

      resources :job_applications, only: [:index, :create, :show]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end