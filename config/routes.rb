# config/routes.rb
# frozen_string_literal: true

require "googleauth"

Rails.application.routes.draw do
  # Google OAuth2 via OmniAuth for user authentication
  get "/login", to: redirect("/auth/google_oauth2")
  get "/logout", to: "sessions#destroy"
  get "/auth/:provider/callback", to: "sessions#omniauth_callback"
  post "/auth/:provider/callback", to: "sessions#omniauth_callback"

  resources :forest_projects do
    get :download_csv, on: :member
    get :reprocess, on: :member
  end

  root "home#index"
end
