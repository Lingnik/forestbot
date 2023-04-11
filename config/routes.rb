Rails.application.routes.draw do
  get '/auth/:provider/callback', to: 'sessions#omniauth'
  get '/login', to: redirect('/auth/google_oauth2')

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root to: 'home#index'
end
