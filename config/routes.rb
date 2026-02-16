Rails.application.routes.draw do
  # Health check (outside locale scope)
  get "up" => "rails/health#show", as: :rails_health_check

  # Locale scope
    # Root
    root "home#index"

    # Authentication
    devise_for :users, controllers: {
      sessions: "users/sessions",
      registrations: "users/registrations",
      confirmations: "users/confirmations",
      passwords: "users/passwords"
    }

    # Route GET pour sign_out (fallback si nécessaire)
    devise_scope :user do
      get "users/sign_out", to: "users/sessions#destroy"
    end

    # OTP verification
    namespace :users do
      resources :otp, only: [:new, :create], path: "otp" do
        collection do
          post :resend
        end
      end
    end

    # Public pages
    resources :gwanas, only: %i[index show], path: "gwanas"
    resources :articles, only: %i[index show]
    resources :gwana_network_requests, only: %i[new create show], path: "gwana_network_requests"
    resources :gwana_activities, only: [:index, :show], path: "activites-gwanas"
    resources :network_events, only: [:index, :show], path: "galeries", controller: "galeries", as: "galeries"
    get "impact", to: "impact#index", as: :impact

    # API routes for location data
    namespace :api do
      get "departments", to: "locations#departments"
      get "communes", to: "locations#communes"
    end

    # Authenticated routes
    authenticate :user do
      # Dashboard
      resource :dashboard, only: [:show]

      # Member profile
      resource :profile, only: %i[show edit update], controller: "profiles"

      # Mentorship
      resources :mentorship_requests, except: [:destroy] do
        member do
          patch :accept
          patch :reject
        end
      end
    end

    # Admin routes
    namespace :admin do
      root "dashboard#show"
      resource :dashboard, only: [:show], controller: "dashboard"
      
      resources :gwanas do
        resources :activities, controller: "gwana_activities", except: [:show]
        resources :portrait_videos, controller: "gwana_portrait_videos", except: [:show]
      end
      resources :mentorship_requests, only: %i[index show]
      resources :gwana_update_requests, only: %i[index show], path: "gwana_update_requests" do
        member do
          patch :approve
          patch :reject
        end
      end
      resources :articles
      resources :network_events, path: "network_events"
      resources :users, only: %i[index show new create edit update]
      resources :gwana_network_requests, only: %i[index show], path: "gwana_network_requests" do
        member do
          patch :approve
          patch :reject
        end
      end
    end

    # Sidekiq web UI (admin only)
    require "sidekiq/web"
    authenticate :user, ->(u) { u.admin? } do
      mount Sidekiq::Web => "/sidekiq"
    end
end
