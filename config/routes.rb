require "googleauth"

Rails.application.routes.draw do
  get '/auth/:provider/callback', to: 'sessions#omniauth_callback'
  post '/auth/:provider/callback', to: 'sessions#omniauth_callback'
  get '/login', to: redirect('/auth/google_oauth2')

  get "/google/authorize", to: "google#authenticate"
  match "/google/oauth2/callback", to: "google#oauth2_callback", via: :all

  resources :forest_projects, only: [:index, :new, :create, :show]

  root 'home#index'
end
