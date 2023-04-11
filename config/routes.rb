Rails.application.routes.draw do
  get '/auth/:provider/callback', to: 'sessions#omniauth'
  get '/login' do
    redirect_to '/auth/google_oauth2'
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root to: 'home#index'
end
