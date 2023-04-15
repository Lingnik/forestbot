# config/routes.rb

require "googleauth"

Rails.application.routes.draw do
  get '/auth/:provider/callback', to: 'sessions#omniauth_callback'
  post '/auth/:provider/callback', to: 'sessions#omniauth_callback'
  get '/login', to: redirect('/auth/google_oauth2')

  get "/google/authorize", to: "google#authenticate"
  match "/google/oauth2/callback", to: "google#oauth2_callback", via: :all

  resources :forest_projects do
    get :download_csv, on: :member
    get :reprocess, on: :member
  end

  root 'home#index'
end
