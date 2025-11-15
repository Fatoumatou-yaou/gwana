# frozen_string_literal: true

Rails.application.routes.draw do
  # Health check (outside locale scope)
  get "up" => "rails/health#show", as: :rails_health_check

  # Locale scope
  scope "(:locale)", locale: /fr|en/ do
    # Root
    root "home#index"

    # Authentication
    devise_for :users, controllers: {
      registrations: "users/registrations",
      confirmations: "users/confirmations"
    }

    # Public pages
    resources :members, only: %i[index show], param: :slug
    resources :articles, only: %i[index show], param: :slug

    # Authenticated routes
    authenticate :user do
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
      root "dashboard#index"
      resources :members
      resources :mentorship_requests, only: %i[index show]
      resources :articles
      resources :users, only: %i[index show edit update]
    end

    # Sidekiq web UI (admin only)
    require "sidekiq/web"
    authenticate :user, ->(u) { u.admin? || u.admin_reseau? } do
      mount Sidekiq::Web => "/sidekiq"
    end
  end
end
